describe AnalyticsController do
  let(:course) { build(:course)}
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }

  context "as a professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET students" do
      it "returns the student analytics page for the current course" do
        get :students
        expect(response).to render_template(:students)
      end
    end

    describe "GET staff" do
      it "returns the staff analytics page for the current course" do
        get :staff
        expect(response).to render_template(:staff)
      end
    end
  end

  context "as a student" do
    before(:each) do
      login_user(student)
    end

    describe "protected routes" do
      [
        :students,
        :staff,
        :all_events,
        :role_events,
        :login_events,
        :login_role_events,
        :all_pageview_events,
        :all_role_pageview_events,
        :all_user_pageview_events,
        :pageview_events,
        :role_pageview_events,
        :user_pageview_events
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route).to redirect_to(:root)
        end
      end
    end
  end
end
