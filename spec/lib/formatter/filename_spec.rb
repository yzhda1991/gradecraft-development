require 'active_support/inflector'
require_relative '../../../lib/formatter/filename'

describe Formatter::Filename do
  subject { described_class.new foo_filename }
  let(:foo_filename) { "some-rando-filename" }

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

    # note that we can't access the filename directly from the #sanitize call
    # because Formatter::Filename#sanitize returns the object rather than the
    # resulting filename attribute

    it "downcases the filename" do
      subject.filename = "SERIOUSLY_THIS_IS_CAPPY"
      expect(result.filename).to eq "seriously this is cappy"
    end

    it "replaces multiple spaces or underscores with single underscores" do
      subject.filename = "roger___   ___went____to    the   mall"
      expect(result.filename).to eq "roger went to the mall"
    end

    it "gets rid of url-unfriendly characters" do
      subject.filename = "####TURTLES&&BRO####"
      expect(result.filename).to eq "turtles bro"
    end

    it "removes leading spaces, hyphens and underscores" do
      subject.filename = "murdoc_is_a_jerk__---   ---"
      expect(result.filename).to eq "murdoc is a jerk"
    end

    it "removes trailing spaces, hyphens and underscores" do
      subject.filename = "jeff_is_nice__---   ---"
      expect(result.filename).to eq "jeff is nice"
    end

    it "returns the object" do
      subject.filename = "stufff"
      expect(result.class).to eq described_class
    end
  end

  describe "#reset!" do
    it "resets the @filename to the @original filename" do
      subject.original_filename = "the-real-filename"
      subject.filename = "some-other-filename"
      subject.reset!
      expect(subject.filename).to eq "the-real-filename"
    end
  end

  describe "INFLECTOR_METHODS" do
    it "returns a list of methods to be included from ActiveSupport::Inflector" do
      expect(Formatter::Filename::INFLECTOR_METHODS).to eq \
        [:camelize, :classify, :constantize, :dasherize, :deconstantize,
         :humanize, :ordinalize, :parameterize, :pluralize, :singularize,
         :tableize, :titleize, :underscore]
    end
  end

  it "includes ActiveSupport::Inflector" do
    expect(subject).to respond_to :camelize
    expect(subject).to respond_to :constantize
    expect(subject).to respond_to :titleize
    expect(subject).to respond_to :tableize
  end
end
