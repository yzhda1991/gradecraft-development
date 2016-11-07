require "rails_spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "#submissions_snapshot" do
    subject { performer.instance_eval { submissions_snapshot }}

    let(:submission) { double(Submission, id: 872, submitter_id: 3800, updated_at: updated_timestamp) }
    let(:updated_timestamp) { Time.parse("Oct 20 1942") }
    let(:snapshot_expectation) {{ 872 => { submitter_id: 3800, updated_at: updated_timestamp.to_s }}}

    before(:each) do
      performer.instance_variable_set(:@submissions_snapshot, nil)
      performer.instance_variable_set(:@submissions, [ submission ])
    end

    it "generates a serialized hash of the submission data" do
      subject
      expect(subject).to eq(snapshot_expectation)
    end

    it "caches the snapshot" do
      subject
    end
  end
end
