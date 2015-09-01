require "spec_helper"

describe FileSizeValidator do
  class Foo
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :media
    validates :media, file_size: true
  end

  let(:image) { fixture_file "test_image.jpg", "img/jpg" }
  subject { Foo.new(media: image) }

  context "when file size is within an acceptable range" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
