module ModelAddons
  module SharedExamples

    RSpec.shared_examples "ModelAddons::ImprovedLogging is included" do

      describe "include ModelAddons::ImprovedLogging" do
        it "responds to logging errors with attributes methods" do
          expect(performer).to respond_to(:log_error_with_attributes)
        end

        it "has valid_logging_types" do
          expect(performer.instance_eval { valid_logging_types }).to include(:error)
        end
      end

    end

  end
end
