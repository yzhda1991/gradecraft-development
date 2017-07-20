require "csv"
require "quote_helper"

class CSVBadgeImporter
  include BadgesHelper
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  EARNED_UNEARNED_BADGE_VALUES ||= [0,1].freeze

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  # def import(course=nil, badge=nil)
  #   if file
  #     if course
  #       students = course.students
  #       CSV.foreach(file, headers: true) do |csv|
  #         row = GradeRow.new csv
  #
  #         student = find_student(row, students)
  #         if student.nil?
  #           append_unsuccessful row, "Student not found in course"
  #           next
  #         end
  #
  #         if !row.has_badge?
  #           append_unsuccessful row, "Grade not specified"
  #           next
  #         end
  #
  #         if !is_valid_grade? assignment, row.grade
  #           append_unsuccessful row, "Grade is invalid"
  #           next
  #         end
  #       end
  #     end
  #   end
  # end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

end
