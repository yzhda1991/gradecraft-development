describe Services::Actions::SendsWelcomeEmail do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:user) { create :user }

  it "expects a user to send the welcome email to" do
    expect { described_class.execute send_welcome_email: true }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the option to send the welcome email" do
    expect { described_class.execute user: user }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "sends the welcome email" do
    expect { described_class.execute user: user, send_welcome_email: true }.to \
      change { ActionMailer::Base.deliveries.count }.by 1
    expect(email.subject).to eq "Welcome to GradeCraft!"
  end
end
