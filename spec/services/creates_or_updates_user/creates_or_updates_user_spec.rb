require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_or_updates_user/creates_or_updates_user"

describe Services::Actions::CreatesOrUpdatesUser do
  let(:course) { create :course }
  let(:user) { build :user }
  let(:attributes) { user.attributes }

  before do
    user_mailer = double(:user_mailer, activation_needed_email: double(:mailer, deliver_now: nil))
    stub_const "UserMailer", user_mailer
  end

  it "expects attributes to assign to the user" do
    expect { described_class.execute course: course, send_welcome_email: false }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects course to assign to the user" do
    expect { described_class.execute attributes: attributes, send_welcome_email: false }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the option to send the welcome email" do
    expect { described_class.execute attributes: attributes, course: course }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "creates the user if they do not exist" do
    expect(Services::CreatesNewUser).to receive(:create).and_call_original
    described_class.execute attributes: attributes, course: course, send_welcome_email: false
  end

  xit "updates the user if they do not exist"
  xit "fails if the attributes do not have an email address to check"
  xit "promises the created or updated user"
end
