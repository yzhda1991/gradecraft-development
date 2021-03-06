RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  describe "fetch_assets" do
    let(:fetch_assets) do
      subject.instance_eval { fetch_assets }
    end

    it "gets the submissions export assignment" do
      fetch_assets
      expect(performer.assignment).to eq submissions_export.assignment
    end

    it "gets the submissions export course" do
      fetch_assets
      expect(performer.course).to eq submissions_export.course
    end

    it "gets the submissions export professor" do
      fetch_assets
      expect(performer.professor).to eq submissions_export.professor
    end

    it "gets the submissions export team" do
      fetch_assets
      expect(performer.team).to eq submissions_export.team
    end

    it "fetches the submitters" do
      expect(performer).to receive(:fetch_submitters)
      fetch_assets
    end

    it "fetches the submitters for the csv" do
      expect(performer).to receive(:fetch_submitters_for_csv)
      fetch_assets
    end

    it "fetches submissions" do
      expect(performer).to receive(:fetch_submissions)
      fetch_assets
    end
  end

  describe "fetch_submitters_for_csv" do
    let(:fetch_submitters_for_csv) do
      performer.instance_eval { fetch_submitters_for_csv }
    end

    context "the submissions export uses groups" do
      it "returns groups for the course" do
        group = double(:group)
        allow(performer.submissions_export).to receive(:use_groups) { true }
        allow(Group).to receive(:where).with(course: course) { [group] }

        expect(fetch_submitters_for_csv).to eq [group]
      end
    end

    context "the submissions export has a team" do
      it "returns the students on the given team" do
        allow(performer.submissions_export).to receive_messages \
          use_groups: false,
          team: true

        allow(User).to receive(:students_being_graded_for_course).with(course, team)
          .and_return [student1, student2]

        expect(fetch_submitters_for_csv).to eq [student1, student2]
      end
    end

    context "submissions export has no team" do
      it "returns all students in the course" do
        allow(performer.submissions_export).to receive_messages \
          use_groups: false,
          team: false

        allow(User).to receive(:students_being_graded_for_course).with(course)
          .and_return [student1, student2]

        expect(fetch_submitters_for_csv).to eq [student1, student2]
      end
    end
  end

  describe "fetch_submitters" do
    let(:fetch_submitters) do
      performer.instance_eval { fetch_submitters}
    end

    context "the SubmissionsExport uses groups" do
      it "returns groups with files" do
        allow(performer.submissions_export).to receive(:use_groups) { true }

        allow(performer.assignment)
          .to receive(:groups_with_files)
          .and_return ["some-groups"]

        expect(fetch_submitters).to eq ["some-groups"]
      end
    end

    context "the SubmissionsExport has a team" do
      it "returns students with files for the team" do
        allow(performer.submissions_export).to receive_messages \
          use_groups: false,
          team: true

        allow(performer.assignment)
          .to receive(:students_with_text_or_binary_files_on_team).with(team)
          .and_return ["some-students"]

        expect(fetch_submitters).to eq ["some-students"]
      end
    end

    context "the SubmissionsExport has no team" do
      it "returns students with files for the team" do
        allow(performer.submissions_export).to receive(:team) { false }

        allow(performer.assignment)
          .to receive(:students_with_text_or_binary_files)
          .and_return ["all-students"]

        expect(fetch_submitters).to eq ["all-students"]
      end
    end
  end

  describe "fetch_submissions" do
    let(:fetch_submissions) do
      performer.instance_eval { fetch_submissions }
    end

    context "the SubmissionsExport uses groups" do
      it "returns group submissions with files" do
        allow(performer.submissions_export).to receive(:use_groups) { true }

        allow(performer.assignment)
          .to receive_message_chain(:submissions, :with_group)
          .and_return ["group-submissions"]

        expect(fetch_submissions).to eq ["group-submissions"]
      end
    end

    context "the SubmissionsExport has a team" do
      it "returns the student submissions with files for the team" do
        allow(performer.submissions_export).to receive(:team) { true }

        allow(performer.assignment)
          .to receive(:student_submissions_with_files_for_team).with(team)
          .and_return submissions

        expect(fetch_submissions).to eq submissions
      end
    end

    context "the SubmissionsExport has no team" do
      it "returns all student submissions with files for the course" do
        allow(performer.submissions_export).to receive(:team) { false }

        allow(performer.assignment)
          .to receive(:student_submissions_with_files)
          .and_return submissions

        expect(fetch_submissions).to eq submissions
      end
    end
  end
end
