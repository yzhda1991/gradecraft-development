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
end
