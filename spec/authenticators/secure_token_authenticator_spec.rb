require 'active_record_spec_helper'
require_relative "../../app/authenticators/secure_token_authenticator"
require_relative "../../config/initializers/regex" unless defined? REGEX

describe SecureTokenAuthenticator do
  subject { described_class.new subject_attrs }

  let(:subject_attrs) {{
    secure_token_uuid: "some_uuid",
    target_class: "WaffleClass",
    secret_key: "skeletonkeysrsly"
  }}
  let(:secure_token) { SecureToken.new }

  describe "#initialize" do
    it "caches the uuid" do
      expect(subject.instance_variable_get(:@secure_token_uuid))
        .to eq("some_uuid")
    end

    it "caches the target class" do
      expect(subject.instance_variable_get(:@target_class))
        .to eq("WaffleClass")
    end

    it "caches the secret key" do
      expect(subject.instance_variable_get(:@secret_key))
        .to eq("skeletonkeysrsly")
    end

    it "sets a slowdown duration of 1 second" do
      expect(subject.instance_variable_get(:@slowdown_duration)).to eq 1
    end
  end

  describe "readable attributes" do
    it "has a readable uuid" do
      expect(subject.secure_token_uuid).to eq("some_uuid")
    end

    it "has a readable target class" do
      expect(subject.target_class).to eq("WaffleClass")
    end

    it "has a readable secret_key" do
      expect(subject.secret_key).to eq("skeletonkeysrsly")
    end

    it "has a slowdown_duration" do
      expect(subject.slowdown_duration).to eq 1
    end
  end

  describe "#authenticates?" do
    let(:result) { subject.authenticates? }
    let(:secure_token) { SecureToken.new }

    before(:each) do
      allow(subject).to receive_messages(
        uuid_format_valid?: true,
        secure_key_format_valid?: true,
        secure_token: secure_token,
        secret_key: "the-secret-key"
      )

      allow(secure_token).to receive(:authenticates_with?)
        .with("the-secret-key").and_return true
    end

    context "all steps return true" do
      it "authenticates" do
        expect(result).to be_truthy
      end
    end

    context "the uuid format is not valid" do
      it "does not authenticate" do
        allow(subject).to receive(:uuid_format_valid?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure key format is not valid" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_key_format_valid?) { false }
        expect(result).to be_falsey
      end
    end

    context "the secure token isn't present" do
      it "does not authenticate" do
        allow(subject).to receive(:secure_token) { nil }
        expect(result).to be_falsey
      end
    end

    context "the secure token doesn't authenticate with the given secret key" do
      before(:each) do
        allow(secure_token).to receive(:authenticates_with?)
          .with("the-secret-key").and_return false
      end

      it "does not authenticate" do
        expect(result).to be_falsey
      end
    end
  end

  describe "#secure_token" do
    let(:result) { subject.secure_token }

    let(:secure_token) do
      create(:secure_token, target_type: "ValidClass")
    end

    context "multiple secure tokens exist with the uuid and target class" do
      let(:subject_attrs) do
        { secure_token_uuid: secure_token.uuid, target_class: "ValidClass" }
      end

      it "returns the first secure token matching this pair" do
        expect(result).to eq(secure_token)
      end

      it "caches the secure token" do
        result
        expect(SecureToken).not_to receive(:where)
        result
      end

      it "sets the secure token to @secure_token" do
        result
        expect(subject.instance_variable_get(:@secure_token))
          .to eq(secure_token)
      end
    end

    context "no secure tokens exist for the uuid and target class" do
      let(:subject_attrs) do
        { secure_token_uuid: "doesnt-exist", target_class: "NotAClass" }
      end

      it "doesn't find anything and returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "checking uuid and secure key formatting" do
    # use this so sleep calls don't delay rspec
    let(:slowdown_duration) { 1e-10 }

    before do
      allow(subject).to receive(:slowdown_duration) { slowdown_duration }
    end

    describe "#uuid_format_valid?" do
      let(:result) { subject.uuid_format_valid? }
      let!(:cached_uuid_regex) { REGEX["UUID"] }

      before do
        REGEX["UUID"] = /VALID-UUID/
      end

      context "secure_token_uuid format matches the regex" do
        it "returns true" do
          allow(subject).to receive(:secure_token_uuid) { "VALID-UUID" }
          expect(result).to be_truthy
        end
      end

      context "secure_token_uuid format does not match the regex" do
        it "returns false" do
          allow(subject).to receive(:secure_token_uuid) { "invalid-uuid" }
          expect(result).to be_falsey
        end

        it "sleeps" do
          expect(subject).to receive(:sleep).with(slowdown_duration)
          result
        end
      end

      after do
        REGEX["UUID"] = cached_uuid_regex
      end
    end

    describe "#secure_key_format_valid?" do
      let(:result) { subject.secure_key_format_valid? }
      let!(:cached_secret_key_regex) { REGEX["190_BIT_SECRET_KEY"] }

      before do
        REGEX["190_BIT_SECRET_KEY"] = /VALID-SECRET-KEY/
        allow(subject).to receive(:sleep) { 0.000000001 } # don't sleep for long
      end

      context "secure_key format matches the regex" do
        it "returns true" do
          allow(subject).to receive(:secret_key) { "VALID-SECRET-KEY" }
          expect(result).to be_truthy
        end
      end

      context "secure_key format does not match the regex" do
        it "returns false" do
          allow(subject).to receive(:secret_key) { "invalid-secret-key" }
          expect(result).to be_falsey
        end

        it "sleeps" do
          expect(subject).to receive(:sleep).with(slowdown_duration)
          result
        end
      end

      after do
        REGEX["UUID"] = cached_secret_key_regex
      end
    end
  end
end
