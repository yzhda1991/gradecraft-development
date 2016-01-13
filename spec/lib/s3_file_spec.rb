require 'rails_spec_helper'

class S3FileCylon
  include S3File
end

RSpec.describe "An S3File inheritor" do
  subject { S3FileCylon.new }

  describe "inclusion of S3Manager::Basics" do
    
    it "responds to S3Manager::Basics methods" do
      expect(subject).to respond_to(:object_attrs)
      expect(subject).to respond_to(:bucket_name)
    end
  end
end
