RSpec.describe ApplicationController do
  let(:student) { create :user }
  let(:instructor) { create :user }

  before { allow(subject).to receive(:current_user).and_return student }

  describe "#register_logout_time_to_db" do
    context "without impersonation" do
      before { allow(subject).to receive(:impersonating?).and_return false }

      it "updates the last logout timestamp for the current user" do
        subject.send :register_logout_time_to_db

        expect(student.last_logout_at).to be_within(1.second).of(DateTime.now)
      end
    end

    context "with impersonation" do
      before do
        allow(subject).to receive(:impersonating?).and_return true
        allow(subject).to receive(:impersonating_agent).and_return instructor
      end

      it "updates the last logout timestamp for the impersonating agent" do
        subject.send :register_logout_time_to_db

        expect(instructor.last_logout_at).to be_within(1.second).of(DateTime.now)
      end
    end
  end

  describe "#register_last_activity_time_to_db" do
    context "without impersonation" do
      before { allow(subject).to receive(:impersonating?).and_return false }

      it "updates the last activity timestamp for the current user" do
        subject.send :register_last_activity_time_to_db

        expect(student.last_activity_at).to be_within(1.second).of(DateTime.now)
      end
    end

    context "with impersonation" do
      before do
        allow(subject).to receive(:impersonating?).and_return true
        allow(subject).to receive(:impersonating_agent).and_return instructor
      end

      it "updates the last activity timestamp for the impersonating agent" do
        subject.send :register_last_activity_time_to_db

        expect(instructor.last_activity_at).to be_within(1.second).of(DateTime.now)
      end
    end
  end

  describe "#register_last_ip_address" do
    context "without impersonation" do
      before { allow(subject).to receive(:impersonating?).and_return false }

      it "updates the last activity ip address for the current user" do
        subject.send :register_last_ip_address, :user, {}

        expect(student.last_login_from_ip_address).to eq "0.0.0.0"
      end
    end

    context "with impersonation" do
      before do
        allow(subject).to receive(:impersonating?).and_return true
        allow(subject).to receive(:impersonating_agent).and_return instructor
      end

      it "updates the last activity ip address for the impersonating agent" do
        subject.send :register_last_ip_address, :user, {}

        expect(instructor.last_login_from_ip_address).to eq "0.0.0.0"
      end
    end
  end
end
