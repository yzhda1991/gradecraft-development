module PerformerToolkit

  module SharedExamples
    RSpec.shared_examples "a fetchable resource" do |resource_name|
      it "fetches the #{resource_name}" do
        expect(subject).to receive(:"fetch_#{resource_name}").and_return send(resource_name.to_sym)
        subject
      end

      it "assigns the #{resource_name} to @#{resource_name}" do
        subject
        expect(subject.instance_variable_get(:"@#{resource_name}")).to eq(send(resource_name.to_sym))
      end
    end
  end

end
