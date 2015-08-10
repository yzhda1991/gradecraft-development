require 'spec_helper'

describe UsersHelper do
  describe "#generate_random_password" do
    it "generates a random password" do
      passwords = 50.times.collect { helper.generate_random_password }
      expect(passwords.uniq.count).to eq 50
    end
  end
end
