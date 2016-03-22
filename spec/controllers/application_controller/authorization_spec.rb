require "rails_spec_helper"

RSpec.describe ApplicationController do
  let(:course) { double(:course) }
  let(:user) { double(:user) }

  before do
    allow(subject).to receive_messages(current_user: user, current_course: course)
  end

  describe "#current_ability" do
    it "uses the current user and course as the context" do
      expect(Ability).to receive(:new).with(user, course).and_call_original
      subject.send :current_ability
    end
  end
end
