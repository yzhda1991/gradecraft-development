RSpec.describe MultipliedGradebookExporterJob do
  include InQueueHelper # pulled from ResqueSpec

  it "queues the job in the proper queue" do
    expect(described_class.queue).to eq :multiplied_gradebook_exporter
  end

  it "runs the correct performer" do
    expect(described_class.performer_class).to eq MultipliedGradebookExportPerformer
  end
end
