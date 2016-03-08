require "rails_spec_helper"
require "active_record_spec_helper"

RSpec.describe SubmissionsExport do
  let(:submissions_export) { SubmissionsExport.new }
  let(:s3_manager) { double(S3Manager::Manager) }
  let(:s3_object_key) { double(:s3_object_key) }

  describe "associations" do
    extend Toolkits::Exports::SubmissionsExportToolkit::Context
    define_association_context

    let(:result) { submissions_export }
    let(:submissions_export) do
      create(:submissions_export, submissions_export_associations)
    end

    it "belongs to a course" do
      expect(result.course).to eq(course)
    end

    it "belongs to a professor" do
      expect(result.professor).to eq(professor)
    end

    it "belongs to a team" do
      expect(result.team).to eq(team)
    end

    it "belongs to an assignment" do
      expect(result.assignment).to eq(assignment)
    end
  end

  describe "#downloadable?" do
    let(:result) { submissions_export.downloadable? }

    context "export has a last_export_completed_at time" do
      it "is downloadable" do
        submissions_export.last_export_completed_at = Time.now
        expect(result).to be_truthy
      end
    end

    context "export doesn't have a last_export_completed_at time" do
      it "isn't download able" do
        submissions_export.last_export_completed_at = nil
        expect(result).to be_falsey
      end
    end
  end

  describe "#created_at_date" do
    let(:result) { submissions_export.created_at_date }
    let(:submissions_export) { create(:submissions_export) }

    it "formats the created_at date" do
      expect(result).to eq(submissions_export.created_at.strftime("%F"))
    end
  end

  describe "#created_at_in_microseconds" do
    let(:submissions_export) { create(:submissions_export) }
    let(:result) { submissions_export.created_at_in_microseconds }

    it "formats the created_at time in microseconds" do
      expect(result).to eq(submissions_export.created_at.to_f.to_s.gsub(".",""))
    end
  end

  describe "validations" do
    describe "course_id" do
      let(:result) { create(:submissions_export, course: nil) }
      it "requires a course_id" do
        expect { result }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "assignment_id" do
      let(:result) { create(:submissions_export, course: nil) }

      it "requires an assignment_id" do
        expect { result }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#rebuild_s3_object_key" do
    before do
      allow(submissions_export).to receive_messages(
        build_s3_object_key: "new-key",
        export_filename: "some_filename.txt"
      )
    end

    it "builds a new s3_object_key and caches it" do
      submissions_export.rebuild_s3_object_key
      expect(submissions_export[:s3_object_key]).to eq "new-key"
    end
  end

  describe "#build_s3_object_key" do
    let(:result) { submissions_export.build_s3_object_key("stuff.zip") }

    let(:submissions_export) { create(:submissions_export) }
    let(:expected_base_s3_key) do
      "exports/courses/40/assignments/50" \
      "/#{submissions_export.created_at_date}" \
      "/#{submissions_export.created_at_in_microseconds}/stuff.zip"
    end

    before(:each) do
      allow(submissions_export).to receive_messages(course_id: 40, assignment_id: 50)
      ENV["AWS_S3_DEVELOPER_TAG"] = "jeff-moses"
    end

    context "env is development" do
      before do
        allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new("development") }
      end

      it "prepends the developer tag to the store dirs and joins them" do
        expect(result).to eq ["jeff-moses", expected_base_s3_key].join("/")
      end
    end

    context "env is anything but development" do
      it "joins the store dirs and doesn't use the developer tag" do
        expect(result).to eq expected_base_s3_key
      end
    end
  end

  describe "#s3_object_key_prefix" do
    let(:result) { submissions_export.s3_object_key_prefix }
    let(:submissions_export) { create(:submissions_export) }
    let(:expected_object_key_prefix) do
      [
        "exports", "courses", 40, "assignments", 50,
        submissions_export.created_at_date,
        submissions_export.created_at_in_microseconds
      ].join "/"
    end

    it "returns the expected pieces" do
      allow(submissions_export).to \
        receive_messages(course_id: 40, assignment_id: 50)
      expect(result).to eq(expected_object_key_prefix)
    end
  end

  describe "#update_export_completed_time" do
    let(:result) { submissions_export.update_export_completed_time }
    let(:sometime) { Date.parse("Oct 20 1982").to_time }
    before { allow(Time).to receive(:now) { sometime } }

    it "calls update_attributes on the submissions export with the export time" do
      expect(submissions_export).to receive(:update_attributes)
        .with(last_export_completed_at: sometime)
      result
    end

    it "updates the last_export_completed_at timestamp to now" do
      result
      expect(submissions_export.last_export_completed_at).to eq(sometime)
    end
  end
end
