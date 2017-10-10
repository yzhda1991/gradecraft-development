include CourseTerms

describe "assignments/_index_staff" do
  let(:course) { create :course, :with_institution }
  let(:assignment_types) { create_list :assignment_type, 2, course: course }
  let(:assignment) { create :assignment, :pass_fail, assignment_type: assignment_types.first, course: course, full_points: 500 }

  before(:each) do
    assignment_types.first.max_points = 1000
    assignment_types.second.max_points = 2000
    assign :assignment_types, [assignment_types.first, assignment_types.second]
    allow(view).to receive(:current_course).and_return course
  end

  describe "pass fail assignments" do
    it "renders pass/fail in the points field" do
      assignment.pass_fail = true
      render
      assert_select "tr#assignment-#{assignment.id}" do
        assert_select "td", text: "Pass/Fail", count: 1
      end
    end
  end
end
