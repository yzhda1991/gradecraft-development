require 'active_record_spec_helper'

RSpec.describe SecureToken do
  describe "polymorphism" do
    it "can belong to a polymorphic target" do
    end
  end

  describe "callbacks" do
    describe "before create" do
      it "caches the encrypted key" do
      end

      it "caches the uuid" do
      end

      it "sets a time-zoned expires_at timestamp" do
      end
    end
  end

  describe "#random_secret_key" do
    it "creates a 190-bit url-safe base64 hex key" do
    end

    it "caches the @random_secret_key" do
    end

    it "sets a @random_secret_key ivar" do
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
      it "sets the :expires_at attribute to 7 days from now with timezone" do
      end
    end

    describe "cache_encrypted_key" do
      it "creates an encrypted key from the secret key and scrypt options" do
      end

      it "sets the encrypted key value to the :encrypted_key attribute on SecureToken" do
      end
    end

    describe "cache_uuid" do
      it "creates random uuid for the SecureToken" do
      end

      it "sets the random uuid value to the :uuid attribute on SecureToken" do
      end
    end
  end
end
