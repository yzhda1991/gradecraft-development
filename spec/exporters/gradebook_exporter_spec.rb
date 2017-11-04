describe GradebookExporter do
  let(:course) { create :course }
  subject { GradebookExporter.new }

  describe "#export" do
    let(:assignment_type) { create :assignment_type, course: course, name: "Charms" }
    let(:assignments) { create_list :assignment, 2, course: course, assignment_type: assignment_type }

    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.gradebook course
      expect(csv).to eq "First Name,Last Name,Email,Username,Team,Earned Badge Score\n"
    end

    it "generates an empty CSV if there are no students" do
      assignments
      csv = subject.gradebook course
      expect(csv).to eq "First Name,Last Name,Email,Username,Team,Earned Badge Score,#{assignments.first.name},#{assignments.second.name}\n"
    end

    it "generates an gradebook CSV if there are students and assignments present" do
      student = create :user, courses: [course], role: :student, last_name: "Aad"
      another_student = create :user, courses: [course], role: :student, last_name: "Zep"
      create :grade, assignment: assignments.first, student: student, raw_points: 100, student_visible: true
      create :grade, assignment: assignments.second, student: student, raw_points: 200, adjustment_points: -100, student_visible: true

      csv = CSV.new(subject.gradebook(course)).read

      expect(csv.length).to eq 3
      expect(csv[1]).to eq [student.first_name, student.last_name, student.email,
        student.username, student.team_for_course(course), "0", "100", "100"]
      expect(csv[2]).to eq [another_student.first_name, another_student.last_name,
        another_student.email, another_student.username, another_student.team_for_course(course), "0", "", ""]
    end
  end
end
