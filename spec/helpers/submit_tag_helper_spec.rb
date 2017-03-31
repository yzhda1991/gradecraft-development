describe SubmitTagHelper do
  include RSpecHtmlMatchers

  describe "#active_course_submit_tag" do
    let(:course) { build_stubbed :course }
    before(:each) { allow(helper).to receive(:current_course).and_return course }

    context "when the current user is not an admin" do
      before(:each) { allow(helper).to receive(:current_user_is_admin?).and_return false }

      it "renders the submit button if the current course is active" do
        course.status = true
        submit_button = helper.active_course_submit_tag("Click to claim your prize!")
        expect(submit_button).to have_tag("input", type: :submit, value: "Click to claim your prize!")
      end

      it "does not render the submit button if the current course is not active" do
        course.status = false
        submit_button = helper.active_course_submit_tag("Click to claim your prize!")
        expect(submit_button).to be_nil
      end
    end

    context "when the current user is an admin" do
      before(:each) { allow(helper).to receive(:current_user_is_admin?).and_return true }

      it "renders the submit button" do
        submit_button = helper.active_course_submit_tag("Click to claim your prize!")
        expect(submit_button).to have_tag("input", type: :submit, value: "Click to claim your prize!")
      end
    end
  end
end
