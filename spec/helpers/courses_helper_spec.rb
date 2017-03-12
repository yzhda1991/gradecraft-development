describe CoursesHelper do
  let(:user) { double(:user) }

  class Helper
    include CoursesHelper

    def current_user
    end
  end

  subject(:helper) { Helper.new }
  before { allow(helper).to receive(:current_user).and_return user }

  describe "#available_roles" do
    let(:course) { double(:couse) }

    context "when current user is an administrator" do
      before do
        allow(user).to receive(:is_professor?).with(course).and_return true
        allow(user).to receive(:is_admin?).with(course).and_return true
      end

      it "includes the admin role" do
        expect(helper.available_roles(course)).to eq [
          ["Student", "student"],
          ["GSI", "gsi"],
          ["Professor", "professor"],
          ["Observer", "observer"],
          ["Admin", "admin"]
        ]
      end
    end

    context "when the current user is a professor" do
      before do
        allow(user).to receive(:is_professor?).with(course).and_return true
        allow(user).to receive(:is_admin?).with(course).and_return false
      end

      it "does not include the admin role" do
        expect(helper.available_roles(course)).to eq [
          ["Student", "student"],
          ["GSI", "gsi"],
          ["Professor", "professor"],
          ["Observer", "observer"]
        ]
      end
    end
  end
end
