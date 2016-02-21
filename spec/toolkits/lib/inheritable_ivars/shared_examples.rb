module Toolkits
  module Lib
    module InheritableIvarsToolkit
      module SharedExamples
        RSpec.shared_examples "some @ivars are inheritable by subclasses" do |superclass|
          describe "ivar inheritance through subclasses" do
            before do
              allow(superclass).to receive(:inheritable_ivars) { [:wallaby_necks] }
              superclass.instance_variable_set(:@wallaby_necks, 5)
              class IvarSubclass < superclass; end
            end

            it "should pass class-level instance variables to subclasses" do
              expect(IvarSubclass.instance_variable_get(:@wallaby_necks)).to eq(5)
            end
          end

          describe "self.inheritable_instance_variable_names" do
            before do
              allow(superclass).to receive(:inheritable_ivars) { [:ostriches, :badgers] }
            end

            it "should return an array of instance variable names" do
              expect(superclass.inheritable_instance_variable_names).to include("@ostriches", "@badgers")
            end
          end
        end
      end
    end
  end
end
