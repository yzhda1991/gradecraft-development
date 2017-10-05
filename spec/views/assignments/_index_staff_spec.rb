include CourseTerms

describe "assignments/_index_staff" do

  before(:all) do
    @institution = create(:institution)
    @course = create(:course, institution: @institution)
    @assignment_type_1 = create(:assignment_type, course: @course, max_points: 1000)
    @assignment_type_2 = create(:assignment_type, course: @course, max_points: 2000)
    @assignment_1 = create(:assignment, assignment_type: @assignment_type_1, full_points: 500)
    @assignment_2 = create(:assignment, assignment_type: @assignment_type_2, full_points: 500)
    @course.assignments <<[@assignment_1,@assignment_2]
  end

  before(:each) do
    assign(:assignment_types, [@assignment_type_1,@assignment_type_2])
    allow(view).to receive(:current_course).and_return(@course)
  end

  describe "pass fail assignments" do
    it "renders pass/fail in the points field" do
      @assignment_1.update(pass_fail: true)
      render
      assert_select "tr#assignment-#{@assignment_1.id}" do
        assert_select "td", text: "Pass/Fail", count: 1
      end
    end
  end
end
