RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "generating the archive from a completed tmp directory" do
    describe "#archive_exported_files (calling the archive utility)" do
      subject { performer.instance_eval { archive_exported_files }}
      let(:archive_root_dir) { performer.instance_eval { archive_root_dir }}
      let(:final_archive_path) { performer.instance_eval { expanded_archive_base_path } + ".zip" }

      it "calls the zip archiver" do
        allow(performer).to receive(:expanded_archive_base_path) { "the_greatest_archive" }
        expect(Archive::Zip).to receive(:archive).with("the_greatest_archive.zip", archive_root_dir)
        subject
      end

      it "actually generates a new archive" do
        subject
        expect(File.exist?(final_archive_path)).to be_truthy
      end

      after(:each) do
        File.delete(final_archive_path) if File.exist?(final_archive_path)
      end
    end
  end
end
