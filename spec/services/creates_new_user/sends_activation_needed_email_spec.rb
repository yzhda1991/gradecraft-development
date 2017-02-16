require "light-service"
require "spec_helper"
require "./app/services/creates_new_user/sends_activation_needed_email"

describe Services::Actions::SendsActivationNeededEmail do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:user) { create :user }

  it "expects a user to save" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sends the activation email if the user is not activated" do
    user.activation_state = :pending
    user.activation_token = "BLAH"
    user.save

    expect { described_class.execute user: user }.to \
      change { ActionMailer::Base.deliveries.count }.by 1
    expect(email.subject).to eq "Welcome to GradeCraft! Please activate your account"
  end
end
