describe CourseGradeExporter do
  let(:course) { create :course }
  subject { CourseGradeExporter.new }

  describe "#final_grades_for_course(course)" do
    let!(:team) { create :team, course: course }

    it "generates an empty CSV if there are no students" do
      csv = subject.final_grades_for_course(course)
      expect(csv).to include "First Name,Last Name,Email,Username,Score,Grade,Level,Team,Earned Badge #,GradeCraft ID,GradeCraft Account Created,Last Logged In At,Auditing"
    end

    it "generates a CSV with student grades for the course" do
      @student = create(:user, first_name: "Pinky", last_name: "Alpha")
      @student_2 = create(:user, first_name: "The Brain", last_name: "Zed")
      create(:course_membership, :student, course: course, user: @student, score: 80000, auditing: true)
      # let!(:team_membership) { create :team_membership, team: team, student: student }
      create(:team_membership, team: team, student: @student)
      create(:team_membership, team: team, student: @student_2)
      @students = course.students
      create(:course_membership, :student, course: course, user: @student_2, score: 120000, auditing: false)
      create(:grade_scheme_element, course: course, level: "Amazing", letter: "B-")
      create(:grade_scheme_element, course: course, lowest_points: 100001, level: "Phenomenal", letter: "B")

      csv = CSV.new(subject.final_grades_for_course(course)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq "Pinky"
      expect(csv[2][0]).to eq "The Brain"
      expect(csv[1][1]).to eq "Alpha"
      expect(csv[2][1]).to eq "Zed"
      expect(csv[1][2]).to eq @student.email
      expect(csv[2][2]).to eq @student_2.email
      expect(csv[1][3]).to eq @student.username
      expect(csv[2][3]).to eq @student_2.username
      expect(csv[1][4]).to eq "80000"
      expect(csv[2][4]).to eq "120000"
      expect(csv[1][5]).to eq "B-"
      expect(csv[2][5]).to eq "B"
      expect(csv[1][6]).to eq "Amazing"
      expect(csv[2][6]).to eq "Phenomenal"
      expect(csv[1][7]).to eq @student.team_for_course(course).name
      expect(csv[2][7]).to eq @student_2.team_for_course(course).name
      expect(csv[1][8]).to eq "0"
      expect(csv[2][8]).to eq "0"
      expect(csv[1][9]).to eq "#{@student.id}"
      expect(csv[2][9]).to eq "#{@student_2.id}"
      expect(csv[1][12]).to eq "Yes"
      expect(csv[2][12]).to eq "No"
    end
  end
end
