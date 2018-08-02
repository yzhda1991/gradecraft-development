describe Services::Actions::CreatesOrUpdatesUser do
  let(:user) { create :user }
  let(:attributes) { user.attributes.symbolize_keys }

  before(:each) do
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
    it "creates the user if one is not found" do
      allow(User).to receive(:find_by_insensitive_email).and_return nil
      allow(User).to receive(:find_by_insensitive_username).and_return nil
      expect(Services::CreatesNewUser).to receive(:call).and_call_original
      expect(Services::UpdatesUser).to_not receive(:call)
      described_class.execute attributes: attributes, send_welcome_email: false
    end

    it "updates the user if one is found" do
      allow(User).to receive(:find_by_insensitive_email).and_return user
      expect(Services::UpdatesUser).to receive(:call).and_call_original
      expect(Services::CreatesNewUser).to_not receive(:call)
      described_class.execute attributes: attributes, send_welcome_email: false
    end

    it "fails if there is no email or username provided" do
      expect(Services::CreatesNewUser).to_not receive(:call)
      expect(Services::UpdatesUser).to_not receive(:call)
      result = described_class.execute attributes: attributes.except(:email, :username), send_welcome_email: false
      expect(result.success?).to be_falsey
    end
  end

  context "when the course is provided in the context" do
    let(:course) { build :course }

    it "creates the user if one is not found" do
      allow(User).to receive(:find_by_insensitive_email).and_return nil
      allow(User).to receive(:find_by_insensitive_username).and_return nil
      expect(Services::CreatesNewUser).to receive(:call).and_call_original
      expect(Services::UpdatesUserForCourse).to_not receive(:call)
      described_class.execute attributes: attributes, course: course, send_welcome_email: false
    end

    it "updates the user if one is found" do
      allow(User).to receive(:find_by_insensitive_email).and_return user
      expect(Services::UpdatesUserForCourse).to receive(:call).and_call_original
      expect(Services::CreatesNewUser).to_not receive(:call)
      described_class.execute attributes: attributes, course: course, send_welcome_email: false
    end

    it "fails if there is no email or username provided" do
      expect(Services::CreatesNewUser).to_not receive(:call)
      expect(Services::UpdatesUserForCourse).to_not receive(:call)
      described_class.execute attributes: attributes.except(:email, :username), course: course, send_welcome_email: false
    end
  end
end
