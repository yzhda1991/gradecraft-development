describe "grades/show" do
  let(:presenter) { Assignments::Presenter.new({ assignment: @assignment, course: @course }) }

  before(:each) do
    @course = create(:course)
    @assignment = create(:assignment)
    @course.assignments << @assignment
    student = create(:user, courses: [@course], role: :student)
    staff = create(:user, courses: [@course], role: :professor)
    @grade = create(:grade, course: @course, assignment: @assignment, student: student)

    allow(view).to receive(:current_student).and_return(student)
    allow(view).to receive(:current_user).and_return(staff)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:presenter).and_return presenter
    allow(view).to receive(:term_for).and_return("Assignments")
  end

  describe "viewed by staff" do
    before(:each) do
      allow(view).to receive(:current_user_is_staff).and_return(true)
    end

    describe "with a raw score" do
      it "renders the points out of possible" do
        @grade.update(student_visible: true, raw_points: @assignment.full_points)
        render
        assert_select "p", text: "#{ points @grade.final_points } / #{ points @assignment.full_points } points earned", count: 1
      end
    end
  end
end
