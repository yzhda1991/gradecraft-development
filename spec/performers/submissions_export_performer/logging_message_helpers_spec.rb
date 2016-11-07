require "rails_spec_helper"

RSpec.describe SubmissionsExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include Toolkits::Performers::SubmissionsExport::SharedExamples
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  describe "logging message helpers" do
    before { performer.instance_variable_set(:@submitters, students) }

    describe "generate_csv_messages" do
      subject { performer.instance_eval{ generate_export_csv_messages } }

      it_behaves_like "an expandable messages hash"
      it_behaves_like "it has a success message", "Successfully generated"
      it_behaves_like "it has a failure message", "Failed to generate the csv"
    end

    describe "generate_csv_messages" do
      subject { performer.instance_eval{ generate_export_json_messages } }

      it_behaves_like "an expandable messages hash"
      it_behaves_like "it has a success message", "Successfully generated the export JSON"
      it_behaves_like "it has a failure message", "Failed to generate the export JSON"
    end

    describe "csv_export_messages" do
      subject { performer.instance_eval{ confirm_export_csv_integrity_messages } }

      it_behaves_like "an expandable messages hash"
      it_behaves_like "it has a success message", "Successfully saved the CSV file"
      it_behaves_like "it has a failure message", "Failed to save the CSV file"
    end

    describe "expand_messages" do
      let(:output) { performer.instance_eval{ expand_messages(success: "great", failure: "bad") } }

      describe "joins the messages with the suffix" do
        before(:each) { allow(performer).to receive(:message_suffix) { "end of transmission" }}

        it "builds the success message" do
          expect(output[:success]).to eq("great end of transmission")
        end

        it "builds the failure message" do
          expect(output[:failure]).to eq("bad end of transmission")
        end
      end

      describe "success" do
        subject { output[:success] }

        it { should include("great") }
        it { should include("assignment #{assignment.id}") }
        it { should include("for students: #{students.collect(&:id)}") }
      end

      describe "failure" do
        subject { output[:failure] }

        it { should include("bad") }
        it { should include("assignment #{assignment.id}") }
        it { should include("for students: #{students.collect(&:id)}") }
      end
    end

    describe "message_suffix" do
      subject { performer.instance_eval{ message_suffix }}

      it { should include("assignment #{assignment.id}") }
      it { should include("for students: #{students.collect(&:id)}") }

    end
  end
end
