describe "assignments/index_student/_assignments" do

  let(:user) { double(:user, is_student?: true) }
  let(:view_context) { double(:view_context, current_user: user) }
  let(:presenter) { Assignments::StudentPresenter.new({ student: @student,
    course: @course, assignment_types: @assignment_types,
    view_context: view_context }) }

  before(:each) do
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course, max_points: 1000)
    @assignment_type_2 = create(:assignment_type, course: @course, max_points: 1000)
    @assignment = create(:assignment, assignment_type: @assignment_type_1, full_points: 500)
    @course.assignment_types << [@assignment_type_1, @assignment_type_2]
    @assignment_types = @course.assignment_types
    @course.assignments << @assignment
    @student = create(:user)
    assign(:assignment_types, @assignment_types)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
    allow(view).to receive(:presenter).and_return presenter
  end

  describe "as student" do
    before(:each) do
      allow(view).to receive(:current_student).and_return(@student)
    end

    it "does not render instructor menu" do
      render
      assert_select "li", text: "Grade", count: 0
    end

    it "renders when assignment is student_logged" do
      @assignment.update(student_logged: true)
      allow_any_instance_of(Assignment).to receive(:open?).and_return(true)
      allow(view).to receive(:current_user_is_student?).and_return(true)
      render
    end

    it "renders with team_challenges and team_score_average" do
      @course.update(has_team_challenges: true)
      @course.update(team_score_average: true)
      render
    end

    describe "when an assignment has points" do

      it "renders the points possible when grade is not released" do
        render
        assert_select "p", text: "#{points @assignment.full_points} points possible", count: 1
      end

      it "renders the points out of points possible when the grade is released" do
        @grade = create(:grade, course: @course, assignment: @assignment, student: @student, raw_points: @assignment.full_points, student_visible: true)

        # To verify we have satisfied the released condition:
        expect(@student.grade_released_for_assignment?(@assignment)).to be_truthy
        render
        assert_select "p", text: "#{ points @grade.score } / #{points @grade.full_points} points earned", count: 1
      end
    end

    describe "when an assignment is pass fail" do

      before(:each) do
        @assignment.update(pass_fail: true)
      end

      it "renders Pass/Fail in the points possible field when grade is not released" do
        render
        assert_select "div", text: "Pass/Fail", count: 1
      end

      it "renders Pass or Fail in the points possible field when a grade is released for assignment" do
        @grade = create(:grade, course: @course, assignment: @assignment, student: @student, pass_fail_status: "Pass", student_visible: true)

        # To verify we have satisfied the released condition:
        expect(@student.grade_released_for_assignment?(@assignment)).to be_truthy

        render
        assert_select "div" do
          assert_select "p", text: "Pass", count: 1
        end
      end
    end

    it "shows the description if it's present" do
      @assignment_type_1.update(description: "Tabula Rasa")
      @assignment_type_1.save
      render
      assert_select "p", text: "Tabula Rasa", count: 1
    end

    it "highlights assignments that are required" do
      @assignment.required = true
      @assignment.save
      render
      assert_select "i.fa-asterisk", count: 1
    end

    it "shows the due date if it's in the future" do
      @assignment.update(due_at: 2.days.from_now)
      render
      assert_select "span", text: "#{(2.days.from_now).strftime("%A, %b %d, %l:%M%p")}", count: 1
    end
  end
end
