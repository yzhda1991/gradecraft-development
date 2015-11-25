require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::AssignmentExport::SharedExamples
  include ModelAddons::SharedExamples

  extend Toolkits::Performers::AssignmentExport::Context
  define_context

  subject { performer }

  describe "error logging" do
    describe "error_log_path" do
      subject { performer.instance_eval { error_log_path }}
      before { allow(performer).to receive(:tmp_dir) { "/some/serious/tmp_dir" } }

      it "expands the error log file relative to the tmp dir" do
        expect(subject).to eq("/some/serious/tmp_dir/error_log.txt")
      end
    end

    describe "generate_error_log" do
    end
  end

end
