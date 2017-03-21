describe GradeExporter do
  let(:assignment) { create :assignment }
  let(:students) { create_list :user, 2 }
  subject { GradeExporter.new }

  describe "#export_grades" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export_grades(nil, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback\n"
    end

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export_grades(assignment, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback\n"
    end

    it "generates a CSV with student scores if the assignment is not pass/fail" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, score: 123, feedback: nil)
      allow(students[1]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, score: 456, feedback: "Grrrrreat!")

      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[2][0]).to eq students[1].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[2][1]).to eq students[1].last_name
      expect(csv[1][2]).to eq students[0].email
      expect(csv[2][2]).to eq students[1].email
      expect(csv[1][3]).to eq "123"
      expect(csv[2][3]).to eq "456"
      expect(csv[1][4]).to eq ""
      expect(csv[2][4]).to eq "Grrrrreat!"
    end

    it "generates a CSV with grade statuses if the assignment is pass/fail" do
      assignment.pass_fail = true
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, score: nil, pass_fail_status: "Pass", feedback: nil)

      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[1][2]).to eq students[0].email
      expect(csv[1][3]).to eq "1"
    end

    it "includes students that do not have grades for the assignment" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return Grade.new
      csv = CSV.new(subject.export_grades(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end
  end

  describe "#export_group_grades" do
    let(:groups) { create_list :group, 2 }

    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export_group_grades(nil, [])
      expect(csv).to eq "Group Name,Score,Feedback\n"
    end

    it "generates an empty CSV if there are no groups specified" do
      csv = subject.export_group_grades(assignment, [])
      expect(csv).to eq "Group Name,Score,Feedback\n"
    end

    it "generates a CSV with student scores if the assignment is not pass/fail" do
      grade1 = double(:grade, score: 123, feedback: nil)
      grade2 = double(:grade, score: 456, feedback: "Grrrrreat!")

      allow(groups.first).to receive(:grade_for_assignment).with(assignment)
          .and_return grade1

      allow(groups.last).to receive(:grade_for_assignment).with(assignment)
          .and_return grade2

      csv = CSV.new(subject.export_group_grades(assignment, groups)).read

      expect(csv.length).to eq 3
      expect(csv[1]).to eq [groups.first.name, "123", ""]
      expect(csv[2]).to eq [groups.last.name, "456", "Grrrrreat!"]
    end

    it "generates a CSV with grade statuses if the assignment is pass/fail" do
      assignment.pass_fail = true
      grade = double(:grade, score: nil, pass_fail_status: "Pass", feedback: nil)
      another_grade = double(:grade, score: nil, pass_fail_status: "Fail", feedback: "We need to talk...")

      allow(groups.first).to receive(:grade_for_assignment).with(assignment)
        .and_return grade
      allow(groups.last).to receive(:grade_for_assignment).with(assignment)
        .and_return another_grade

      csv = CSV.new(subject.export_group_grades(assignment, groups)).read

      expect(csv.length).to eq 3
      expect(csv[1]).to eq [groups.first.name, "1", ""]
      expect(csv[2]).to eq [groups.last.name, "0", "We need to talk..."]
    end

    it "includes groups that do not have grades for the assignment" do
      allow(groups.first).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return Grade.new

      csv = CSV.new(subject.export_group_grades(assignment, groups)).read
      expect(csv.last.last).to eq ""
    end
  end


  describe "#export_grades_with_detail" do
    it "generates an empty CSV if there is no assignment specified" do
      csv = subject.export_grades_with_detail(nil, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback,Raw Score,Statement,Last Updated\n"
    end

    it "generates an empty CSV if there are no students specified" do
      csv = subject.export_grades_with_detail(assignment, [])
      expect(csv).to eq "First Name,Last Name,Email,Score,Feedback,Raw Score,Statement,Last Updated\n"
    end

    it "generates a CSV with student grades for the assignment" do
      updated_at = DateTime.now
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: true, graded_or_released?: false,
                              score: 123, raw_points: 789, feedback: nil, graded_at: updated_at)
      allow(students[1]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: false, graded_or_released?: true,
                              score: 456, raw_points: 456, feedback: "Grrrrreat!", graded_at: updated_at)
      allow(students[1]).to \
        receive(:submission_for_assignment).with(assignment)
          .and_return double(:submission, text_comment: "Hello there")

      csv = CSV.new(subject.export_grades_with_detail(assignment, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[2][0]).to eq students[1].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[2][1]).to eq students[1].last_name
      expect(csv[1][2]).to eq students[0].email
      expect(csv[2][2]).to eq students[1].email
      expect(csv[1][3]).to eq "123"
      expect(csv[2][3]).to eq "456"
      expect(csv[1][4]).to eq ""
      expect(csv[2][4]).to eq "Grrrrreat!"
      expect(csv[1][5]).to eq "789"
      expect(csv[2][5]).to eq "456"
      expect(csv[1][6]).to eq ""
      expect(csv[2][6]).to eq "Hello there"
      expect(csv[1][7]).to eq "#{updated_at}"
      expect(csv[2][7]).to eq "#{updated_at}"
    end

    it "includes students that do not have grades for the assignment" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return Grade.new
      csv = CSV.new(subject.export_grades_with_detail(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end

    it "does not include the grade if it has not been graded or released" do
      allow(students[0]).to \
        receive(:grade_for_assignment).with(assignment)
          .and_return double(:grade, instructor_modified?: false, graded_or_released?: false)
      csv = CSV.new(subject.export_grades_with_detail(assignment, students)).read
      expect(csv[1][3]).to eq ""
    end
  end

  describe "#group_headers" do
    it "has an array of headers for group grades" do
      expect(subject.group_headers).to eq ["Group Name", "Score", "Feedback"]
    end

    it "is frozen" do
      expect(subject.group_headers.frozen?).to eq true
    end
  end
end
