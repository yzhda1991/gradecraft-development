require "active_record_spec_helper"
require "./app/exporters/course_grade_exporter"

describe CourseGradeExporter do
  let(:course) { create :course }
  subject { CourseGradeExporter.new }

  describe "#final_grades_for_course(course, students)", focus: true do

    it "generates an empty CSV if there are no students specified" do
      csv = subject.final_grades_for_course(course, nil)
      expect(csv).to include 'First Name,Last Name,Email,Username,Score,Grade,Level,Earned Badge #,GradeCraft ID'
    end

    it "generates a CSV with student grades for the course" do
      let(:students) { create_list :user, 2 }
      updated_at = DateTime.now
      allow(students[0]).to \
        receive(:cached_score_for_course).with(course)
          .and_return double(:course_membership, score: 123, course: course)
      allow(students[1]).to \
        receive(:cached_score_for_course).with(course)
          .and_return double(:course_membership, score: 456, course: course)

      csv = CSV.new(subject.final_grades_for_course(course, students)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq students[0].first_name
      expect(csv[2][0]).to eq students[1].first_name
      expect(csv[1][1]).to eq students[0].last_name
      expect(csv[2][1]).to eq students[1].last_name
      expect(csv[1][2]).to eq students[0].email
      expect(csv[2][2]).to eq students[1].email
      expect(csv[1][2]).to eq students[0].username
      expect(csv[2][2]).to eq students[1].username
      expect(csv[1][3]).to eq "123"
      expect(csv[2][3]).to eq "456"
    end

  end

end
