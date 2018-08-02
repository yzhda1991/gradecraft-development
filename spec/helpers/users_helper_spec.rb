describe UsersHelper do
  class Helper
    include UsersHelper
  end

  subject(:helper) { Helper.new }

  describe "#cancel_course_memberships" do
    let(:service) { double(:cancels_course_memberships) }
    before { stub_const("Services::CancelsCourseMembership", service) }

    it "cancels any course memberships that are marked for deletion" do
      active_course_membership = double(:course_membership, marked_for_destruction?: false)
      deleted_course_membership = double(:course_membership, marked_for_destruction?: true)
      user = double(:user, course_memberships: [active_course_membership, deleted_course_membership])
      expect(service).to receive(:call).with(deleted_course_membership)
      helper.cancel_course_memberships user
    end
  end
end
