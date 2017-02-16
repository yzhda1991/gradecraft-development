require "spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "error logging" do
    describe "error_log_path" do
      subject { performer.instance_eval { error_log_path }}
      before { allow(performer).to receive(:archive_root_dir) { "/some/serious/archive_root_dir" } }

      it "expands the error log file relative to the tmp dir" do
        expect(subject).to eq("/some/serious/archive_root_dir/error_log.txt")
      end
    end

    describe "generate_error_log" do
      subject { performer.instance_eval { generate_error_log }}
      let(:stubbed_error_log_path) { "/tmp/error_log_stuff.txt" }
      let(:errors) { ["ralph fell", "more stuff broke"] }
      let(:errors_with_newlines) { errors.collect {|e| "#{e}\n" }}

      before(:each) do
        allow(performer).to receive(:error_log_path) { stubbed_error_log_path }
        performer.instance_variable_set(:@errors, errors)
      end

      it "writes the file to the error_log_path" do
        subject
        expect(File.exist?(stubbed_error_log_path)).to be_truthy
      end

      it "receives the error_log_path message" do
        expect(performer).to receive(:error_log_path)
        subject
      end

      it "writes the errors to the file" do
        subject
        expect(File.new(stubbed_error_log_path).readlines).to eq(errors_with_newlines)
      end

      after(:each) do
        File.delete stubbed_error_log_path if File.exist?(stubbed_error_log_path)
      end
    end
  end

end
