describe AnnouncementState do
  describe ".for_course" do
    it "returns all the announcement states for a specific course" do
      course = create(:course)
      course_announcement_state = create(:announcement_state,
                            announcement: create(:announcement, course: course))
      another_announcement_state = create(:announcement_state)
      results = AnnouncementState.for_course(course)
      expect(results).to eq [course_announcement_state]
    end
  end

  describe ".for_user" do
    it "returns all the announcement states for a specific student" do
      user = create(:user)
      user_announcement_state = create(:announcement_state, user: user)
      another_announcement_state = create(:announcement_state)
      results = AnnouncementState.for_user(user)
      expect(results).to eq [user_announcement_state]
    end
  end
end
