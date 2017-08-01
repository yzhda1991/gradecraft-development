require "csv"
require "quote_helper"

class CSVBadgeImporter
  include BadgesHelper
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  EARNED_UNEARNED_BADGE_VALUES ||= [0,1].freeze

  def initialize(file, current_user, current_course)
    @file = file
    @current_user = current_user
    @current_course = current_course
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  def import(badge=nil)
    if file
      if @current_course
        students = @current_course.students
        CSV.foreach(file, headers: true) do |csv|
          row = BadgeRow.new csv

          student = find_student(row, students)
          if student.nil?
            append_unsuccessful row, "Student not found in course"
            next
          end

          if !row.has_earned? #check earned column, should be an integer, if blank it should skip
            append_unsuccessful row, "Earned unspecified"
            next
          end

          if !is_valid_badge? row.earned
            append_unsuccessful row, "Badge row is invalid"
            next
          end

          if Integer(row.earned) != 1
            next
          end

          earned_badge = @current_course.earned_badges.where(student_id: student.id, badge_id: badge.id).first
          earned_badge_count = @current_course.earned_badges.where(student_id: student.id, badge_id: badge.id).count

          if Integer(row.earned) == earned_badge_count
            unchanged << earned_badge
          end

          if earned_badge.nil?
            earned_badge = create_badge row, badge, student
            report row, earned_badge
          end
        end
      end
    end

    self
  end

  private

  def find_student(row, students)
    message = row.identifier =~ /@/ ? :email : :username
    students.find do |student|
      student.public_send(message).downcase == row.identifier
    end
  end

  # Ensures that the input is valid and integer-like
  def is_valid_badge?(earned)
    begin
      return false if earned.nil?
      # Integer() vs to_i to prevent unwanted coercion
      return EARNED_UNEARNED_BADGE_VALUES.include?(Integer(earned))
      true
    rescue ArgumentError
      false
    end
  end

  def create_badge(row, badge, student)
    @current_course.earned_badges.create do |earned_badge|
      assign_badge row, badge, student, earned_badge
    end
  end

  def assign_badge(row, badge, student, earned_badge)
    earned_badge.badge_id = badge.id
    earned_badge.course_id = @current_course.id
    earned_badge.student_id = student.id
    earned_badge.grade = nil
    earned_badge.feedback = nil
    earned_badge.level_id = nil
    earned_badge.student_visible = true
    earned_badge.awarded_by_id = @current_user.id
  end

  def report(row, earned_badge)
    if earned_badge.valid?
      successful << earned_badge
    else
      append_unsuccessful row, earned_badge.errors.full_messages.join(", ")
    end
  end

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  class BadgeRow
    include QuoteHelper
    attr_reader :data

    def identifier
      remove_smart_quotes(data[2]).downcase if data[2].present?
    end

    def earned
      remove_smart_quotes(data[3])
    end

    # def feedback
    #   remove_smart_quotes data[4]
    # end
    #

    def has_earned?
      earned.present?
    end

    def initialize(data)
      @data = data
    end

    def to_s
      data.to_s
    end
  end

end
