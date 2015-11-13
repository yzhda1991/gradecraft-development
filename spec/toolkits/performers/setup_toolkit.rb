module PerformerToolkit

  module SharedExamples
    RSpec.shared_examples "a fetchable resource" do |resource_name, resource_klass|
      let(:expected_klass) { resource_klass || resource_name.to_s.camelize.constantize }

      it "fetches the #{resource_name}" do
        expect(performer).to receive(:"fetch_#{resource_name}").and_return send(resource_name.to_sym)
        subject
      end

      it "assigns the #{resource_name} to @#{resource_name}" do
        subject
        expect(performer.instance_variable_get(:"@#{resource_name}")).to eq(send(resource_name.to_sym))
      end

      it "fetches an object that actually has the correct class" do
        subject
        expect(performer.instance_variable_get(:"@#{resource_name}").class).to eq(expected_klass)
      end
    end

    RSpec.shared_examples "a collection of fetchable resources" do |resource_name, resource_klass|
      let(:expected_klass) { resource_klass || resource_name.to_s.camelize.constantize }

      it "fetches the #{resource_name}" do
        expect(performer).to receive(:"fetch_#{resource_name}").and_return send(resource_name.to_sym)
        subject
      end

      it "assigns the #{resource_name} to @#{resource_name}" do
        subject
        expect(performer.instance_variable_get(:"@#{resource_name}")).to eq(send(resource_name.to_sym))
      end

      it "fetches objects that actually have the #{expected_klass} class" do
        subject
        performer.instance_variable_get(:"@#{resource_name}").each do |resource|
          expect(resourse.class).to eq(expected_klass)
        end
      end
    end
  end

end
