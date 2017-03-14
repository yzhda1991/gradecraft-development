describe AssignmentTypeExporter do
  let(:course) { create :course }
  let(:students) { create_list :user, 2 }
  subject { AssignmentTypeExporter.new }
  let!(:assignment_type_1) { create(:assignment_type, course: course, name: "Charms", position: 1) }
  let!(:assignment_type_2) { create(:assignment_type, course: course, name: "History of Wizardry", position: 2) }
  let!(:assignment) { create(:assignment, course: course, assignment_type: assignment_type_1) }
  let!(:assignment_2) { create(:assignment, course: course, assignment_type: assignment_type_1) }
  let!(:assignment_3) { create(:assignment, course: course, assignment_type: assignment_type_2) }
  let!(:student) { create(:user, courses: [course], role: :student) }

  before(:each) do
    @assignment_types = course.assignment_types
  end

  describe "#export_summary_scores" do

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export_summary_scores(@assignment_types, course, [])
      expect(csv).to include "First Name,Last Name,Email,Username,Team,Charms,History of Wizardry"
    end

    it "generates a CSV with scores if students and grades are present" do
      create(:grade, assignment: assignment, student: student, raw_points: 100, status: "Released" )
      create(:grade, assignment: assignment_2, student: student, raw_points: 200, status: "Released")
      create(:grade, assignment: assignment_3, student: student, raw_points: 200, status: "Released")

      csv = CSV.new(subject.export_summary_scores(@assignment_types, course, course.students)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq student.first_name
      expect(csv[1][1]).to eq student.last_name
      expect(csv[1][2]).to eq student.email
      expect(csv[1][3]).to eq student.username
      expect(csv[1][4]).to eq student.team_for_course(course)
      expect(csv[1][5]).to eq "300"
      expect(csv[1][6]).to eq "200"
    end

  end

  describe "#export_scores" do
    it "generates an empty CSV if there are no students specified" do
      csv = subject.export_scores(assignment_type_1, course, [])
      expect(csv).to include "First Name,Last Name,Email,Username,Team,Raw Score,Score"
    end

    it "generates a CSV with scores if students and grades are present" do
      create(:grade, assignment: assignment, student: student, raw_points: 100, status: "Released" )
      create(:grade, assignment: assignment_2, student: student, raw_points: 200, status: "Released")
      create(:grade, assignment: assignment_3, student: student, raw_points: 200, status: "Released")

      csv = CSV.new(subject.export_scores(assignment_type_1, course, course.students)).read
      expect(csv.length).to eq 2
      expect(csv[1][0]).to eq student.first_name
      expect(csv[1][1]).to eq student.last_name
      expect(csv[1][2]).to eq student.email
      expect(csv[1][3]).to eq student.username
      expect(csv[1][4]).to eq student.team_for_course(course)
      expect(csv[1][5]).to eq "300"
      expect(csv[1][6]).to eq "300"
    end
  end
end
