require "active_record_spec_helper"
require "./app/exporters/gradebook_exporter"

describe GradebookExporter do
  let(:course) { create :course }
  subject { GradebookExporter.new }

  describe "#export" do
    it "generates an empty CSV if there are no students or assignments" do
      csv = subject.gradebook(course)
      expect(csv).to eq "First Name,Last Name,Email,Username,Team\n"
    end

    it "generates an empty CSV if there are no students" do
      @assignment = create(:assignment, course: course, name: "The Flash!")
      csv = subject.gradebook(course)
      expect(csv).to eq "First Name,Last Name,Email,Username,Team,The Flash!\n"
    end

    it "generates an gradebook CSV if there are students and assignments present" do
      @assignment_type_1 = create(:assignment_type, course: course, name: "Charms")
      @assignment = create(:assignment, course: course, assignment_type: @assignment_type_1)
      @assignment_2 = create(:assignment, course: course, assignment_type: @assignment_type_1)
      @student = create(:user, last_name: "Aad", courses: [course], role: :student)
      @student_2 = create(:user, last_name: "Zep", courses: [course], role: :student)
      create(:grade, assignment: @assignment, student: @student, raw_points: 100, status: "Released" )
      create(:grade, assignment: @assignment_2, student: @student, raw_points: 200, status: "Released")

      csv = CSV.new(subject.gradebook(course)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq @student.first_name
      expect(csv[2][0]).to eq @student_2.first_name
      expect(csv[1][1]).to eq @student.last_name
      expect(csv[2][1]).to eq @student_2.last_name
      expect(csv[1][2]).to eq @student.email
      expect(csv[2][2]).to eq @student_2.email
      expect(csv[1][3]).to eq @student.username
      expect(csv[2][3]).to eq @student_2.username
      expect(csv[1][4]).to eq @student.team_for_course(course)
      expect(csv[2][4]).to eq @student_2.team_for_course(course)
      expect(csv[1][5]).to eq "100"
      expect(csv[2][5]).to eq ""
      expect(csv[1][6]).to eq "200"
      expect(csv[2][6]).to eq ""
    end
  end
end
