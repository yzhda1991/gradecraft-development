require "spec_helper"
require "./lib/historical/history_token_parser"

describe HistoryTokenParser do
  it "initializes with a tokenizer" do
    tokenizer = double(:history_tokenizer)
    expect(described_class.new(tokenizer).tokenizer).to eq tokenizer
  end

  describe "#parse" do
    class TestToken
      attr_writer :parse

      def parse(options={})
        @parse
      end

      def initialize(parse=nil)
        @parse = parse
      end

      def self.token
        :token
      end
    end

    let(:tokenizer) { double(:history_tokenizer) }
    subject { described_class.new tokenizer }

    before { allow(tokenizer).to receive(:tokenize).and_return tokenizer }

    it "parses all of the tokens in the tokenizer" do
      token = TestToken.new({ token: "blah" })
      allow(tokenizer).to receive(:tokens).and_return [token]
      expect(subject.parse).to eq({ token: "blah" })
    end

    it "merges all the parsed tokens" do
      token1 = TestToken.new({ token1: "blah" })
      token2 = TestToken.new({ token2: "bleh" })
      allow(tokenizer).to receive(:tokens).and_return [token1, token2]
      expect(subject.parse).to eq({ token1: "blah", token2: "bleh" })
    end

    it "merges parsed tokens of the same key and joins them with and" do
      token1 = TestToken.new({ token: "blah" })
      token2 = TestToken.new({ token: "bleh" })
      allow(tokenizer).to receive(:tokens).and_return [token1, token2]
      expect(subject.parse).to eq({ token: "blah and bleh" })
    end
  end
end
