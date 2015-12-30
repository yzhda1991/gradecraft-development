require "spec_helper"
require "./app/models/history_token_parser"

describe HistoryTokenParser do
  it "initializes with a tokenizer" do
    tokenizer = double(:history_tokenizer)
    expect(described_class.new(tokenizer).tokenizer).to eq tokenizer
  end

  describe "#parse" do
    let(:tokenizer) { double(:history_tokenizer) }
    subject { described_class.new tokenizer }

    before { allow(tokenizer).to receive(:tokenize).and_return tokenizer }

    it "parses all of the tokens in the tokenizer" do
      token = double(:token, parse: { token: "blah" })
      allow(tokenizer).to receive(:tokens).and_return [token]
      expect(subject.parse).to eq({ token: "blah" })
    end

    it "merges all the parsed tokens" do
      token1 = double(:token, parse: { token1: "blah" })
      token2 = double(:token, parse: { token2: "bleh" })
      allow(tokenizer).to receive(:tokens).and_return [token1, token2]
      expect(subject.parse).to eq({ token1: "blah", token2: "bleh" })
    end

    xit "merges parsed tokens of the same key"
  end
end
