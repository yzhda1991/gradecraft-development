require 'spec_helper'

RSpec.describe AssignmentExportsController, type: :controller do
  context "as a professor" do
    before do
      @course = create(:course_accepting_groups)
      @students = []
      create_professor_for_course
      create_assignment_for_course
      create_students_for_course(2)

      login_user(@professor)
      session[:course_id] = @course.id
      allow(Resque).to receive(:enqueue).and_return(true)
    end

    describe "GET export_submissions", working: true do
      before(:each) do
        @controller = AssignmentExportsController.new

        @submission1 = {id: 1, student: 
          {first_name: "Ben", last_name: "Bailey", id: 40}},
        @submission2 = {id: 2, student:
          {first_name: "Mike", last_name: "McCaffrey", id: 55}},
        @submission3 = {id: 3, student:
          {first_name: "Dana", last_name: "Dafferty", id: 92}}
        @submission4 = {id: 4, student:
          {first_name: "Mike", last_name: "McCaffrey", id: 55}},

        @submissions = [@submission1, @submission2, @submission3, @submission4]

        @grouped_submission_expectation = {
          "bailey_ben-40" => [@submission1],
          "mccaffrey_mike-50" => [@submission2, @submission4],
          "dafferty_dana-92" => [@submission3]
        }

        @controller.instance_variable_set("@submissions", @submissions)
      end

      context "grouping students" do
        it "should group students by 'last_name_first_name-id'" do
          @controller.instance_eval { group_submissions_by_student }
        end
      end
    end

    describe "GET export_team_submissions", working: true do
      context "students on active team" do
        it "gets students on the active team" do
          skip
        end

        it "does not included students from other team" do
          skip
        end

        it "should have as many students as the active team" do
          skip
        end
      end
    end

  end

  # helper methods
  def create_student_for_course
    # return just one user and not a whole array
    # because arrays are for fools
    create_students_for_course(1).first
  end

  def create_students_for_course(total=1)
    (1..total).collect do |student_number|
      # sets instance variables as @student1, @student2 etc.
      n = student_number + 1 + @students.size
      student = create(:user)
      self.instance_variable_set("@student#{n}", student)
      enroll_student_in_active_course(student)
      student
    end
  end

  def create_students_with_names(*student_names)
    User.where(username: student_names.collect {|n| n.sub(/ /,".").downcase }).destroy_all
    student_names.inject([]) do |memo, name|
      # get an index for the @studentSOME# instance varible relative to the object's @students array
      # @student3, @student4 etc.
      n = memo.size + 1 + @students.size

      # create and name the student
      student = create(:user, first_name: name.split.first, last_name: name.split.last, username: name.sub(/ /,".").downcase)

      # set the instance variable '@studentSOME#'
      self.instance_variable_set("@student#{n}", student)

      # enroll the damn student in the durn course already
      enroll_student_in_active_course(student)

      # add the student to the memo so you can count it and don't have to use a durn tally
      memo << student
    end
  end

  def create_teamless_student_with_submission
    student = create_student_for_course
    grade = grade_student_for_active_assignment(student)
    create(:submission, grade: grade, student: student, assignment: @assignment)
  end

  def enroll_student_in_active_course(student)
    CourseMembership.create user_id: student[:id], course_id: @course[:id], role: "student"
  end

  def grade_student_for_active_assignment(student)
    create(:grade, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
  end

  def create_submissions_for_students
    @students.collect do |student|
      grade = grade_student_for_active_assignment(student)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment, course: @course)
      submission
    end
  end

  def create_professor_for_course
    @professor = create(:user)
    CourseMembership.create user_id: @professor[:id], course_id: @course[:id], role: "professor"
  end

  def create_assignment_for_course
    @assignment_type = create(:assignment_type, course: @course)
    @assignment = create(:assignment, assignment_type: @assignment_type, course: @course)
  end

  def create_team_and_add_students
    @team = create(:team, course: @course)
    @students.each do |student|
      create(:team_membership, team: @team, student: student)
    end
  end

end
