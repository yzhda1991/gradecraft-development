require "spec_helper"

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
      expect(service).to receive(:for_student).with(deleted_course_membership)
      helper.cancel_course_memberships user
    end
  end

  describe "#total_scores_for_chart" do
    it "handles the summing of earned badges, including old badges cached with nil points" do
      course = double(:course, assignment_types: [], badge_term: "Badgeinskies", total_points: 0)

      earned_badges = double(:earned_badges, sum: 1000)
      user = double(:user, earned_badges: earned_badges)
      expect(helper.total_scores_for_chart(user,course)).to eq({scores: [{ data: [1000], name: "Badgeinskies" }], course_total: 1000 })
    end
  end
end
