require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include ModelAddons::SharedExamples

  # public methods
  let(:course) { @course ||= create(:course) }
  let(:professor_course_membership) { @professor_course_membership ||= create(:professor_course_membership, course: course) }
  let(:professor) { @professor ||= professor_course_membership.user }
  let(:assignment) { @assignment ||= create(:assignment, course: course) }
  let(:team) { @team ||= create(:team) }
  let(:student_course_membership1) { @student_course_membership1 ||= create(:student_course_membership, course: course) }
  let(:student_course_membership2) { @student_course_membership2 ||= create(:student_course_membership, course: course) }
  let(:students) { @students ||= [ student_course_membership1.user, student_course_membership2.user ] }

  let(:job_attrs) {{ professor_id: professor.id, assignment_id: assignment.id }}
  let(:job_attrs_with_team) { job_attrs.merge(team_id: team.try(:id)) }

  let(:performer) { AssignmentExportPerformer.new(job_attrs) }
  let(:performer_with_team) { AssignmentExportPerformer.new(job_attrs_with_team) }

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  describe "public methods" do

    describe "fetch_assets" do
      subject { performer.instance_eval { fetch_assets }}

      describe "assignment submissions export" do
        it_behaves_like "a fetchable resource", :professor, User # this is a User object fetched as 'professor'
        it_behaves_like "a fetchable resource", :assignment
        it_behaves_like "a fetchable resource", :course
      end

      describe "team submissions export" do
        let(:performer) { performer_with_team }
        it_behaves_like "a fetchable resource", :team
      end
    end

    describe "fetch_students" do
      context "a team is present" do
        let(:students_ivar) { performer_with_team.instance_variable_get(:@students) }
        subject { performer_with_team.instance_eval { fetch_students }}

        before(:each) do
          allow(performer_with_team).to receive(:team_present?) { true }
          performer_with_team.instance_variable_set(:@course, course)
          allow(course).to receive(:students_being_graded_by_team) { students}
        end

        it "returns the students being graded for that team" do
          expect(course).to receive(:students_being_graded_by_team).with(team)
          subject
        end

        it "fetches the students" do
          subject
          expect(students_ivar).to eq(students)
        end
      end

      context "no team is present" do
        let(:students_ivar) { performer.instance_variable_get(:@students) }
        subject { performer.instance_eval { fetch_students }}

        before(:each) do
          allow(performer).to receive(:team_present?) { false }
          performer.instance_variable_set(:@course, course)
          allow(course).to receive(:students_being_graded) { students }
        end

        it "returns students being graded for the course" do
          expect(course).to receive(:students_being_graded)
          subject
        end

        it "fetches the students" do
          subject
          expect(students_ivar).to eq(students)
        end
      end
    end

    describe "do_the_work" do
      after(:each) { subject.do_the_work }

      context "work resources are present" do
        before do
          allow(subject).to receive(:work_resources_present?) { true }
        end

        it "should require success" do
          expect(subject).to receive(:require_success).exactly(1).times
        end

        it "should add outcomes to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(1)
        end

        it "should fetch the csv data" do
          allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
          expect(subject).to receive(:generate_export_csv)
        end
      end

      context "work resources are not present" do
        before do
          allow(subject).to receive(:work_resources_present?) { false }
        end

        after(:each) { subject.do_the_work }

        it "should not require success" do
          expect(subject).not_to receive(:require_success)
        end

        it "should not add outcomes to subject.outcomes" do
          expect { subject.do_the_work }.not_to change { subject.outcomes.size }
        end

        it "should not fetch the csv data" do
          allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
          expect(subject).not_to receive(:generate_export_csv)
        end
      end
    end
  end

  describe "attributes" do
    let(:default_attributes) {{
      assignment_id: assignment.id,
      course_id: course.id,
      professor_id: professor.id,
      student_ids: students.collect(&:id),
      team_id: nil
    }}
    before(:each) { performer.instance_variable_set(:@students, students) }

    context "team is not present" do
      it "doesn't have a team_id" do
        expect(performer.attributes).to eq(default_attributes)
      end
    end

    context "team is present" do
      let(:performer) { performer_with_team }
      it "has a team_id" do
        expect(performer.attributes).to eq(default_attributes.merge(team_id: team.id))
      end
    end
  end

  # private methods
  
  describe "tmp_dir", focus: true do
    subject { performer.instance_eval { tmp_dir }}
    it "builds a temporary directory" do
      expect(subject).to match(/\/tmp\/[\w\d-]+/) # match the tmp dir hash
    end

    it "caches the temporary directory" do
      original_tmp_dir = subject
      expect(subject).to eq(original_tmp_dir)
    end
  end
  
  describe "work_resources_present?" do
    let(:assignment_present) { performer.instance_variable_set(:@assignment, true) }
    let(:assignment_not_present) { performer.instance_variable_set(:@assignment, false) }
    let(:students_present) { performer.instance_variable_set(:@students, true) }
    let(:students_not_present) { performer.instance_variable_set(:@students, false) }

    subject { performer.instance_eval { work_resources_present? }}

    context "both @assignment and @students are present" do
      before { assignment_present; students_present }
      it { should be_truthy }
    end

    context "@assignment is present but @students are not" do
      before { assignment_present; students_not_present }
      it { should be_falsey }
    end

    context "@students is present but @assignment is not" do
      before { students_present; assignment_not_present }
      it { should be_falsey }
    end

    context "neither @students nor @assignment are present" do
      before { students_not_present; assignment_not_present }
      it { should be_falsey }
    end
  end
  
  describe "private methods" do
    describe "generate_csv_messages" do
      let(:messages) { performer.instance_eval{ generate_csv_messages } }
      before(:each) { performer.instance_variable_set(:@students, students) }

      describe "success" do
        subject { messages[:success] }

        it { should match('Successfully generated') }
        it { should include("assignment #{assignment.id}") }
        it { should include("for students: #{students.collect(&:id)}") }
      end

      describe "failure" do
        subject { messages[:failure] }

        it { should match('Failed to generate the csv') }
        it { should include("assignment #{assignment.id}") }
        it { should include("for students: #{students.collect(&:id)}") }
      end
    end
  end
end
