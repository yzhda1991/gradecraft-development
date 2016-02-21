module Toolkits
  module Lib
    module InheritableIvarsToolkit
      module SharedExamples
        RSpec.shared_examples "some @ivars are inheritable by subclasses" do |target_class|
          describe "ivar inheritance through subclasses" do
            let(:subclass_name) { "#{target_class.to_s.gsub(/\W/,"")}TestClass" }
            let(:subclass_constant) { subclass_name.constantize }

            before do
              puts subclass_name
              allow(target_class).to receive(:inheritable_ivars) { [:wallaby_necks] }
              target_class.instance_variable_set(:@wallaby_necks, 5)
              # define a temporary subclass that inherits from target_class
              Object.const_set(subclass_name, Class.new(target_class))
            end

            it "should pass class-level instance variables to subclasses" do
              expect(subclass_constant.instance_variable_get(:@wallaby_necks)).to eq(5)
            end
          end

          describe "self.inheritable_instance_variable_names" do
            before do
              allow(target_class).to receive(:inheritable_ivars) { [:ostriches, :badgers] }
            end

            it "should return an array of instance variable names" do
              expect(target_class.inheritable_instance_variable_names).to include("@ostriches", "@badgers")
            end
          end
        end
      end
    end
  end
end
