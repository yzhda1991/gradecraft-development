require "csv"
require "quote_helper"

class CSVBadgeImporter
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  def initialize(file, current_user, current_course)
    @file = file
    @current_user = current_user
    @current_course = current_course
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  def import(badge=nil)
    if file && @current_course
      students = @current_course.students_being_graded
      CSV.foreach(file, headers: true, encoding: "iso-8859-1:utf-8") do |csv|
        row = BadgeRow.new csv

        student = find_student(row, students)
        if student.nil?
          append_unsuccessful row, "Active student not found in course"
          next
        end

        if !is_valid_badge? row.current_badges_total, row.new_badges_total
          append_unsuccessful row, "Badge row is invalid"
          next
        end

        earned_badge = @current_course.earned_badges.where(student_id: student.id, badge_id: badge.id).first
        earned_badge_count = @current_course.earned_badges.where(student_id: student.id, badge_id: badge.id).count

        if row.new_badges_total.empty?
          # Record in sample file wasn't changed so we assume Instructor didn't intend to see any changes
          next
        end

        (1..Integer(row.new_badges_total)).each do |i|
          earned_badge = create_badge row, badge, student
          report row, earned_badge
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
  def is_valid_badge?(current_badges_total, new_badges_total)
    begin
      return false if current_badges_total.nil?
      # Using custom method to check if integer because Integer() will return 0 for words like "ten"
      return false if !is_an_intiger?(current_badges_total)
      return false if !is_an_intiger?(new_badges_total)
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
    earned_badge.feedback = row.feedback unless row.feedback.length == 0
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
    unsuccessful << { data: row.to_s.split(","), errors: errors }
  end

  def is_an_intiger?(value_to_check)
    return true if value_to_check.nil? || value_to_check.empty?
    !!(value_to_check =~ /\A[-+]?[0-9]+\z/)
  end

  class BadgeRow
    include QuoteHelper
    attr_reader :data

    def identifier
      remove_smart_quotes(data[2]).downcase if data[2].present?
    end

    def new_badges_total
      remove_smart_quotes(data[3])
    end

    def feedback
      remove_smart_quotes(data[4])
    end

    def current_badges_total
      remove_smart_quotes(data[5])
    end

    def has_earned?
      new_badges_total.present?
    end

    def initialize(data)
      @data = data
    end

    def to_s
      data.to_s
    end
  end

end
