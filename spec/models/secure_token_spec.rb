require 'active_record_spec_helper'

RSpec.describe SecureToken do
  subject { SecureToken.new }

  describe "polymorphism" do
    it "can belong to a polymorphic target" do
    end
  end

  describe "#random_secret_key" do
    let(:result) { subject.instance_eval { random_secret_key } }

    it "creates a 190-bit url-safe base64 hex key" do
      expect(result).to match(/[a-zA-Z0-9_\-]{254}/)
    end

    it "caches the @random_secret_key" do
      result
      expect(SecureRandom).not_to receive(:urlsafe_base64).with(190)
      result
    end

    it "sets a @random_secret_key ivar" do
      result
      expect(subject.instance_variable_get(:@random_secret_key)).to eq result
    end
  end

  describe "#authenticates_with?" do
    it "creates a password with the secret key and scrypt options" do
    end

    it "checks the password against the encrypted key" do
    end
  end

  describe "#secret_url" do
    it "generates a url with the secret key for the secure download" do
    end
  end

  describe "#has_valid_target_of_class?" do
    context "SecureToken has a target and the target class matches the required class" do
      it "returns true" do
      end
    end

    context "no target is present" do
      it "returns false" do
      end
    end

    context "target is present but the target class doesn't match the required class" do
      it "returns false" do
      end
    end
  end

  describe "protected methods" do

    describe "#set_expires_at" do
      let(:result) { subject.instance_eval { set_expires_at } }
      let(:time_now) { Date.parse("Oct 20 1999").to_time }

      before { allow(Time).to receive(:now) { time_now } }

      it "sets the :expires_at attribute to 7 days from now with timezone" do
        result
        expect(subject[:expires_at]).to eq(time_now + 7.days)
      end

      describe "caching :expires_at on create" do
        it "caches the encrypted key on create" do
          subject.save
          expect(subject[:expires_at]).to eq(time_now + 7.days)
        end
      end
    end

    describe "#cache_encrypted_key" do
      let(:result) { subject.instance_eval { cache_encrypted_key } }
      let(:subject_attrs) do
        { random_secret_key: "stuffkey!!", scrypt_options: {} }
      end

      before do
        allow(subject).to receive_messages(subject_attrs)
        allow(SCrypt::Password).to receive(:create) { "some-encrypted-key" }
      end

      it "creates an encrypted key from the secret key and scrypt options" do
        expect(SCrypt::Password).to receive(:create).with("stuffkey!!", {})
        result
      end

      it "sets the encrypted key value to the :encrypted_key attribute on SecureToken" do
        result
        expect(subject[:encrypted_key]).to eq("some-encrypted-key")
      end

      describe "caching :encrypted_key on create" do
        it "caches the encrypted key on create" do
          subject.save
          expect(subject[:encrypted_key]).to eq("some-encrypted-key")
        end
      end
    end

    describe "#cache_uuid" do
      let(:result) { subject.instance_eval { cache_uuid } }

      before do
        allow(SecureRandom).to receive(:uuid) { "find-this-uuid" }
      end

      it "creates random uuid for the SecureToken" do
        expect(result).to eq "find-this-uuid"
      end

      it "sets the random uuid value to the :uuid attribute on SecureToken" do
        result
        expect(subject[:uuid]).to eq "find-this-uuid"
      end

      describe "caching :uuid on create" do
        it "caches the uuid on create" do
          subject.save
          expect(subject[:uuid]).to eq("find-this-uuid")
        end
      end
    end

    describe "#scrypt_options" do
      let(:result) { subject.instance_eval { scrypt_options } }

      it "creates random uuid for the SecureToken" do
        expect(result).to eq({ key_len: 512 })
      end
    end

  end
end
