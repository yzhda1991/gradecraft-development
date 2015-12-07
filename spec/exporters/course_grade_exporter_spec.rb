require "active_record_spec_helper"
require "./app/exporters/course_grade_exporter"

describe CourseGradeExporter do
  let(:course) { create :course }
  let(:students) { create_list :user, 2 }
  subject { CourseGradeExporter.new }

  describe "#final_grades_for_course(course)" do

    it "generates an empty CSV if there are no students specified" do
      csv = subject.final_grades_for_course(course)
      expect(csv).to include 'First Name,Last Name,Email,Username,Score,Grade'
    end

  end

end