require 'active_support/inflector'
require_relative '../../../lib/formatter/filename'

describe Formatter::Filename do
  subject { described_class.new foo_filename }
  let(:foo_filename) { Tempfile.new 'some-file' }

  describe "#initialize" do
    it "sets the @filename and @original_filename" do
      expect(subject.filename).to eq foo_filename
      expect(subject.original_filename).to eq foo_filename
    end
  end

  describe "accessible attributes" do
    it "has an accessible filename" do
      subject.filename = "rex harrison"
      expect(subject.filename).to eq "rex harrison"
    end

    it "has an accessible original filename" do
      subject.original_filename = "rex chapman"
      expect(subject.original_filename).to eq "rex chapman"
    end
  end

  describe "#sanitize" do
    let(:result) { subject.sanitize }

    it "downcases the filename" do
      # note that we can't access the filename directly from the #sanitize call
      # because Formatter::Filename#sanitize returns the object rather than the
      # resulting filename attribute
      subject.filename = "SERIOUSLY_THIS_IS_CAPPY"
      expect(subject.sanitize.filename).to eq "seriously_this_is_cappy"
    end
  end
end
