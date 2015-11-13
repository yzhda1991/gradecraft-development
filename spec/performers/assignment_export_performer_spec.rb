require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include ModelAddons::SharedExamples

  # public methods
  let(:professor) { create(:user) }
  let(:assignment) { create(:assignment, course: course) }
  let(:course) { create(:course) }
  let(:team) { create(:team) }

  let(:job_attrs) {{ professor_id: professor.id, assignment_id: assignment.id }}
  let(:job_attrs_with_team) { job_attrs.merge(team_id: team.try(:id)) }

  let(:performer) { AssignmentExportPerformer.new(job_attrs) }
  let(:performer_with_team) { AssignmentExportPerformer.new(job_attrs_with_team) }

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  describe "public methods" do

    describe "fetch_assets", focus: true do
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
      let(:students_double) { double(:students) }

      context "a team is present" do
        let(:students_ivar) { performer_with_team.instance_variable_get(:@students) }
        subject { performer_with_team.instance_eval { fetch_students }}

        before(:each) do
          allow(performer_with_team).to receive(:team_present?) { true }
          performer.instance_variable_set(:@course, course)
          allow(course).to receive(:students_being_graded_by_team) { students_double }
        end

        it "returns the students being graded for that team" do
          expect(course).to receive(:students_being_graded_by_team).with(team)
          subject
        end

        it "fetchs the students" do
          subject
          expect(students_ivar).to eq(students_double)
        end
      end

      context "no team is present" do
        let(:students_ivar) { performer.instance_variable_get(:@students) }
        subject { performer.instance_eval { fetch_students }}

        before(:each) do
          allow(performer).to receive(:team_present?) { false }
          performer.instance_variable_set(:@course, course)
          allow(course).to receive(:students_being_graded) { students_double }
        end

        it "returns students being graded for the course" do
          expect(course).to receive(:students_being_graded)
          subject
        end

        it "fetches the students" do
          subject
          expect(students_ivar).to eq(students_double)
        end
      end
    end

    describe "do_the_work" do
      context "both course and user present" do
        after(:each) do
          subject.do_the_work
        end

        it "should require success" do
          expect(subject).to receive(:require_success).exactly(2).times
        end

        it "should add outcomes to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(2)
        end

        it "should fetch the csv data" do
          allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
          expect(subject).to receive(:generate_export_csv)
        end

        it "should mail notification that the gradebook was exported" do
          expect(subject).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_gradebook_export: @export_result)
          allow(subject).to receive(:fetch_csv_data).and_return "some,csv,data"
          expect(subject).to receive(:require_success).and_return(@export_result)
          expect(subject).to receive(:require_success).and_return("some,csv,data")
        end

        describe "require_success" do
          describe "notify_gradebook_export requirement" do
            context "block outcome fails" do
              it "should add the :success outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: true)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was successfully delivered")
              end
            end

            context "block outcome succeeds" do
              it "should add the :failure outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: false)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was not delivered")
              end
            end
          end
        end
      end

    end
  end


  # private methods
  
  describe "private methods" do
    describe "generate_csv_messages" do
      subject { performer.instance_eval{ generate_csv_messages } }
      it "should have a success message" do
        expect(subject[:success]).to match('Successfully generated')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('Failed to generate CSV')
      end
    end
  end
end
