require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_or_updates_user/creates_or_updates_user"

describe Services::Actions::CreatesOrUpdatesUser do
  let(:user) { build :user }
  let(:attributes) { user.attributes.symbolize_keys }

  before do
    user_mailer = double(:user_mailer, activation_needed_email: double(:mailer, deliver_now: nil))
    stub_const "UserMailer", user_mailer
  end

  it "expects attributes to assign to the user" do
    expect { described_class.execute send_welcome_email: false }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the option to send the welcome email" do
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the created or updated user" do
    result = described_class.execute attributes: attributes, send_welcome_email: false
    expect(result).to have_key :user
  end

  context "when the course is not provided in the context" do
    it "creates the user if they do not exist" do
      expect(Services::CreatesNewUser).to receive(:create).and_call_original
      expect(Services::UpdatesUser).to_not receive(:update)
      described_class.execute attributes: attributes, send_welcome_email: false
    end

    it "updates the user if they already exist" do
      user.save!
      expect(Services::UpdatesUser).to receive(:update).and_call_original
      expect(Services::CreatesNewUser).to_not receive(:create)
      described_class.execute attributes: attributes, send_welcome_email: false
    end

    it "fails if the attributes do not have an email address to check" do
      attributes.delete(:email)
      expect(Services::CreatesNewUser).to_not receive(:create)
      expect(Services::UpdatesUser).to_not receive(:update)
      described_class.execute attributes: attributes, send_welcome_email: false
    end
  end

  context "when the course is provided in the context" do
    let(:course) { create :course }

    it "creates the user if they do not exist" do
      expect(Services::CreatesNewUser).to receive(:create).and_call_original
      expect(Services::UpdatesUserForCourse).to_not receive(:update)
      described_class.execute attributes: attributes, course: course, send_welcome_email: false
    end

    it "updates the user if they already exist" do
      user.save!
      expect(Services::UpdatesUserForCourse).to receive(:update).and_call_original
      expect(Services::CreatesNewUser).to_not receive(:create)
      described_class.execute attributes: attributes, course: course, send_welcome_email: false
    end

    it "fails if the attributes do not have an email address to check" do
      attributes.delete(:email)
      expect(Services::CreatesNewUser).to_not receive(:create)
      expect(Services::UpdatesUserForCourse).to_not receive(:update)
      described_class.execute attributes: attributes, course: course, send_welcome_email: false
    end
  end
end
