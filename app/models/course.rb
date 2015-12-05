require_relative "role"

class Course < ActiveRecord::Base
  include UploadsMedia

  after_create :create_admin_memberships

  # Note: we are setting the role scopes as instance methods,
  # not class methods, so that they are limited to the users
  # of the current course
  Role.all.each do |role|
    define_method(role.pluralize) do
      User.with_role_in_course(role, self)
    end
  end

  def instructors_of_record
    User.instructors_of_record(self)
  end

  def instructors_of_record_ids
    instructors_of_record.map(&:id)
  end

  def instructors_of_record_ids=(value)
    user_ids = value.map(&:to_i)

    # Remove instructors of record that are not in the array of ids
    course_memberships.select do |membership|
      membership.instructor_of_record && !user_ids.include?(membership.user_id)
    end.each do |membership|
      membership.instructor_of_record = false
      membership.save
    end

    # Add instructors of record that are in the array of ids
    course_memberships.select do |membership|
      !membership.instructor_of_record && user_ids.include?(membership.user_id)
    end.each do |membership|
      membership.instructor_of_record = true
      membership.save
    end
  end

  # Staff returns all professors and GSI for the course.
  # Note that this is different from is_staff? which currently
  # includes Admin users
  def staff
    User.with_role_in_course("staff", self)
  end

  def students_being_graded
    User.students_being_graded(self)
  end

  def students_being_graded_by_team(team)
    User.students_being_graded(self,team)
  end

  def students_auditing
    User.students_auditing(self)
  end

  def students_auditing_by_team(team)
    User.students_auditing(self,team)
  end

  def students_by_team(team)
    User.students_by_team(self, team)
  end

  attr_accessible :courseno, :name,
    :semester, :year, :badge_setting, :team_setting,
    :team_term, :user_term, :section_leader_term, :group_term,
    :user_id, :course_id, :homepage_message, :group_setting,
    :character_names, :team_roles, :character_profiles,
    :total_assignment_weight, :assignment_weight_close_at,
    :assignment_weight_type, :has_submissions, :teams_visible,
    :weight_term, :max_group_size, :min_group_size,
    :max_assignment_weight, :assignments, :default_assignment_weight, :accepts_submissions,
    :tagline, :academic_history_visible, :office, :phone, :class_email,
    :twitter_handle, :twitter_hashtag, :location, :office_hours, :meeting_times,
    :use_timeline, :show_see_details_link_in_timeline, :assignment_term,
    :challenge_term, :badge_term, :grading_philosophy, :team_score_average,
    :team_challenges, :team_leader_term, :max_assignment_types_weighted,
    :point_total, :in_team_leaderboard, :grade_scheme_elements_attributes,
    :add_team_score_to_student, :status, :assignments_attributes,
    :start_date, :end_date, :pass_term, :fail_term, :syllabus, :hide_analytics,
    :instructors_of_record_ids, :lti_uid

  with_options :dependent => :destroy do |c|
    c.has_many :student_academic_histories
    c.has_many :assignment_types
    c.has_many :assignments
    c.has_many :announcements
    c.has_many :badges
    c.has_many :challenges
    c.has_many :challenge_grades, :through => :challenges
    c.has_many :earned_badges
    c.has_many :grade_scheme_elements
    c.has_many :grades
    c.has_many :groups
    c.has_many :group_memberships
    c.has_many :submissions
    c.has_many :teams
    c.has_many :course_memberships
    c.has_many :events
  end

  has_many :users, :through => :course_memberships
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :assignments

  mount_uploader :syllabus, CourseSyllabusUploader

  accepts_nested_attributes_for :grade_scheme_elements, allow_destroy: true

  validates_presence_of :name, :courseno
  validates_numericality_of :max_group_size, :allow_nil => true, :greater_than_or_equal_to => 1
  validates_numericality_of :min_group_size, :allow_nil => true, :greater_than_or_equal_to => 1

  validates_numericality_of :total_assignment_weight, :allow_blank => true
  validates_numericality_of :max_assignment_weight, :allow_blank => true
  validates_numericality_of :max_assignment_types_weighted, :allow_blank => true
  validates_numericality_of :default_assignment_weight, :allow_blank => true
  validates_numericality_of :point_total, :allow_blank => true

  validates_format_of :twitter_hashtag, :with => /\A[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*\z/, :allow_blank => true, :length   => { :within => 3..20 }

  validate :max_more_than_min

  scope :alphabetical, -> { order('courseno ASC') }
  scope :active, -> { where(status: true) }
  scope :inactive, -> { where.not(status: true) }

  def self.find_or_create_by_lti_auth_hash(auth_hash)
    criteria = { lti_uid: auth_hash['extra']['raw_info']['context_id'] }
    where(criteria).first || create!(criteria) do |c|
      c.lti_uid = auth_hash['extra']['raw_info']['context_id']
      c.courseno = auth_hash['extra']['raw_info']['context_label']
      c.name = auth_hash['extra']['raw_info']['context_title']
      c.year = Date.today.year
    end
  end

  def assignment_term
    super.presence || 'Assignment'
  end

  def badge_term
    super.presence || 'Badge'
  end

  def challenge_term
    super.presence || 'Challenge'
  end

  def fail_term
    super.presence || 'Fail'
  end

  def group_term
    super.presence || 'Group'
  end

  def pass_term
    super.presence || "Pass"
  end

  def team_term
    super.presence || 'Team'
  end

  def team_leader_term
    super.presence || 'Team Leader'
  end

  def weight_term
    super.presence || 'Multiplier'
  end

  def user_term
    super.presence || 'Player'
  end

  def has_teams?
    team_setting == true
  end

  def has_team_challenges?
    team_challenges == true
  end

  def teams_visible?
    teams_visible == true
  end

  def in_team_leaderboard?
    in_team_leaderboard == true
  end

  def has_badges?
    badge_setting == true
  end

  def valuable_badges?
    badges.any? { |badge| badge.point_total.present? && badge.point_total > 0 }
  end

  def has_groups?
    group_setting == true
  end

  def min_group_size
    super.presence || 2
  end

  def max_group_size
    super.presence || 6
  end

  def formatted_tagline
    if tagline.present?
      tagline
    else
      " "
    end
  end

  def formatted_short_name
    if semester.present? && year.present?
      "#{self.courseno} #{(self.semester).capitalize.first[0]}#{self.year}"
    else
      "#{courseno}"
    end
  end

  #total number of points 'available' in the course - sometimes set by an instructor as a cap, sometimes just the sum of all assignments
  def total_points
    point_total || assignments.sum('point_total')
  end

  def active?
    status == true
  end

  def student_weighted?
    total_assignment_weight.to_i > 0
  end

  def assignment_weight_open?
    assignment_weight_close_at.nil? || assignment_weight_close_at > Time.now
  end

  def team_roles?
    team_roles == true
  end

  def has_submissions?
    accepts_submissions == true
  end

  def grade_level_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('level').first
  end

  def grade_letter_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('letter').first
  end

  def element_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).first
  end

  def membership_for_student(student)
    course_memberships.detect { |m| m.user_id == student.id }
  end

  def assignment_weight_for_student(student)
    student.assignment_weights.where(:course_id => self.id).pluck('weight').sum
  end

  def assignment_weight_spent_for_student(student)
    assignment_weight_for_student(student) >= total_assignment_weight.to_i
  end

  def score_for_student(student)
    course_memberships.where(:user_id => student).first.score
  end

  #Descriptive stats of the grades
  def minimum_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").minimum('score')
  end

  def maximum_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").maximum('score')
  end

  def average_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").average('score').to_i
  end

  def student_count
    students.count
  end

  def graded_student_count
    students_being_graded.count
  end

  def point_total_for_challenges
    challenges.pluck('point_total').sum
  end

  def recalculate_student_scores
    ordered_student_ids.each do |student_id|
      ScoreRecalculatorJob.new(user_id: student_id, course_id: self.id).enqueue
    end
  end

  def ordered_student_ids
    User
      .unscoped # clear the default scope
      .joins(:course_memberships)
      .where("course_memberships.course_id = ? and course_memberships.role = ?", self.id, "student")
      .select(:id) # only need the ids, please
      .order("id ASC")
      .collect(&:id)
  end

  #Export Users and Final Scores for Course
  def self.csv_summary_data
    CSV.generate(options) do |csv|
      csv << ["Email", "First Name", "Last Name", "Score", "Grade", "Earned Badge #", "GradeCraft ID"  ]
      students.each do |student|
        csv << [ student.email, student.first_name, student.last_name, student.cached_score_for_course(self), student.grade_level_for_course(course), student.earned_badges.count, student.id  ]
      end
    end
  end

  def self.csv_roster
    CSV.generate(options) do |csv|
      csv << ["GradeCraft ID, First Name", "Last Name", "Uniqname", "Score", "Grade", "Feedback", "Team"]
      students.each do |student|
        csv << [student.id, student.first_name, student.last_name, student.username, "", "", "", student.team_for_course(self).try(:name) ]
      end
    end
  end

  def self.csv_assignments
    CSV.generate() do |csv|
      csv << ["ID", "Name", "Point Total", "Description", "Open At", "Due At", "Accept Until"  ]
      assignments.each do |assignment|
        csv << [ assignment.id, assignment.name, assignment.point_total, assignment.description, assignment.open_at, assignment.due_at, assignment.accepts_submissions_until  ]
      end
    end
  end

  #final grades - total score + grade earned in course
  def final_grades_for_course(course, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score", "Grade" ]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.email, student.cached_score_for_course(course), student.grade_letter_for_course(course)]
      end
    end
  end

  #gradebook spreadsheet export for course
  # todo: refactor this, maybe into a Gradebook class
  def csv_gradebook
    CSV.generate do |csv|
      @gradebook = Course::Gradebook.new(self)

      csv << @gradebook.assignment_columns
      self.students.each do |student|
        csv << @gradebook.student_data_for(student)
      end
    end
  end

  #gradebook spreadsheet export for course
  def csv_multiplied_gradebook
    CSV.generate do |csv|
      @multiplied_gradebook = Course::MultipliedGradebook.new(self)

      csv << @multiplied_gradebook.assignment_columns
      self.students.each do |student|
        csv << @multiplied_gradebook.student_data_for(student)
      end
    end
  end

  # todo: add unit tests for this somewhere else
  class Gradebook
    def initialize(course)
      @course = course
    end

    def base_assignment_columns
      ["First Name", "Last Name", "Email", "Username", "Team"]
    end

    def base_column_methods
      [:first_name, :last_name, :email, :username]
    end

    def assignments
      @assignments ||= @course.assignments.sort_by(&:created_at)
    end

    def assignment_columns
      base_assignment_columns + assignment_name_columns
    end

    def assignment_name_columns
      assignments.collect(&:name)
    end

    def student_data_for(student)
      # add the base column names
      student_data = base_column_methods.inject([]) do |memo, method|
        memo << student.send(method)
      end
      # todo: we need to pre-fetch the course teams for this
      student_data << student.team_for_course(@course).try(:name)

      # add the grades for the necessary assignments, todo: improve the performance here
      assignments.inject(student_data) do |memo, assignment|
        grade = assignment.grade_for_student(student)
        if grade and grade.is_student_visible?
          memo << grade.try(:raw_score)
        else
          memo << ''
        end
        memo
      end
    end
  end

  class MultipliedGradebook < Gradebook
    def assignment_name_columns
      assignments.collect do |assignment|
        [ assignment.name, assignment.name ]
      end.flatten
    end

    def student_data_for(student)
      # add the base column names
      student_data = base_column_methods.inject([]) do |memo, method|
        memo << student.send(method)
      end
      # todo: we need to pre-fetch the course teams for this
      student_data << student.team_for_course(@course).try(:name)

      # add the grades for the necessary assignments, todo: improve the performance here
      assignments.inject(student_data) do |memo, assignment|
        grade = assignment.grade_for_student(student)
        if grade and grade.is_student_visible?
          memo << grade.try(:score)
        end
        memo
      end
    end
  end


  # todo: needs to be refactored as a CSV exporter
  def research_grades_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Course ID", "Uniqname", "First Name", "Last Name", "GradeCraft ID", "Assignment Name", "Assignment ID", "Assignment Type", "Assignment Type Id", "Score", "Assignment Point Total", "Multiplied Score", "Predicted Score", "Text Feedback", "Submission ID", "Submission Creation Date", "Submission Updated Date", "Graded By", "Created At", "Updated At"]
      self.grades.each do |grade|
        csv << [self.id, grade.student.username, grade.student.first_name, grade.student.last_name, grade.student_id, grade.assignment.name, grade.assignment.id, grade.assignment.assignment_type.name, grade.assignment.assignment_type_id, grade.raw_score, grade.point_total, grade.score, grade.predicted_score, grade.feedback, grade.submission_id, grade.submission.try(:created_at), grade.submission.try(:updated_at), grade.graded_by_id, grade.created_at, grade.updated_at]
      end
    end
  end

  #all awarded badges for a single course
  def earned_badges_for_course
    CSV.generate do |csv|
      csv << ["First Name", "Last Name", "Uniqname", "Email", "Badge ID", "Badge Name", "Feedback", "Awarded Date" ]
      earned_badges.each do |earned_badge|
        csv << [
          earned_badge.student.first_name,
          earned_badge.student.last_name,
          earned_badge.student.username,
          earned_badge.student.email,
          earned_badge.badge.id,
          earned_badge.badge.name,
          earned_badge.feedback,
          earned_badge.created_at
        ]
      end
    end
  end

  #badges
  def course_badge_count
   badges.count
  end

  def awarded_course_badge_count
   earned_badges.count
  end

  def max_more_than_min
    if (max_group_size? && min_group_size?) && (max_group_size < min_group_size)
      errors.add :base, 'Maximum group size must be greater than minimum group size.'
    end
  end

  private

  def create_admin_memberships
    User.where(admin: true).each do |admin|
      CourseMembership.create course_id: self.id, user_id: admin.id, role: "admin"
    end
  end

end
