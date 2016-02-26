require 'rails_spec_helper'

describe UserSessionsController, type: :controller do
  let(:user) { create :user }

  describe "POST create" do
    context "user is successfully logged in" do
      it "records the course login event" do
        allow(subject).to receive(:login) { user }
        expect(subject).to receive(:record_course_login_event)
        post :create, user: user.attributes
      end
    end

    context "user is not logged in" do
      it "does not record the course login event" do
        allow(subject).to receive(:login) { nil }
        expect(subject).to_not receive(:record_course_login_event)
        post :create, user: user.attributes
      end
    end

  end
end
