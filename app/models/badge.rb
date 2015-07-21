class Badge < ActiveRecord::Base

  attr_accessible :name, :description, :icon, :icon_cache, :visible, :can_earn_multiple_times, :value,
  :multiplier, :point_total, :earned_badges, :earned_badges_attributes, :score, :badge_file_ids,
  :badge_files_attributes, :badge_file, :position, :unlock_conditions, :unlock_conditions_attributes,
  :visible_when_locked

  # grade points available to the predictor from the assignment controller
  attr_accessor :student_predicted_earned_badge

  acts_as_list scope: :course

  mount_uploader :icon, BadgeIconUploader

  has_many :earned_badges, :dependent => :destroy
  has_many :predicted_earned_badges, :dependent => :destroy

  belongs_to :course, touch: true

  # Unlocks
  has_many :unlock_conditions, :as => :unlockable, :dependent => :destroy 
  accepts_nested_attributes_for :unlock_conditions, allow_destroy: true, :reject_if => proc { |a| a['condition_type'].blank? || a['condition_id'].blank? }
  
  has_many :unlock_states, :as => :unlockable, :dependent => :destroy

  accepts_nested_attributes_for :earned_badges, allow_destroy: true, :reject_if => proc { |a| a['score'].blank? }

  has_many :badge_files, :dependent => :destroy
  accepts_nested_attributes_for :badge_files

  validates_presence_of :course, :name
  validates_numericality_of :point_total, :allow_blank => true

  scope :visible, -> { where(visible: true) }

  default_scope { order('position ASC') }
  #TODO: remove calls to sorted, default scope is sorted
  scope :sorted, -> { order('position ASC') }


  def self.with_earned_badge_info_for_student(student)
    joins("LEFT JOIN earned_badges on badges.id = earned_badges.id AND earned_badges.student_id = #{Badge.sanitize(student.id)}").select('badges.*, earned_badges.created_at AS earned_at, earned_badges.feedback')
  end

  def can_earn_multiple_times
    super || false
  end

  #indexed badges
  def awarded_count
    earned_badges.count
  end

  # Checking to see if the badge has unlock conditions
  def is_unlockable?
    unlock_conditions.present?
  end

  def is_unlocked_for_student?(student)
    if unlock_states.where(:student_id => student.id).present?
      unlock_states.where(:student_id => student.id).first.is_unlocked?
    end
  end

  def is_a_condition?
    UnlockCondition.where(:condition_id => self.id, :condition_type => "Badge").present?
  end

  def check_unlock_status(student)
    if ! is_unlocked_for_student?(student)
      goal = unlock_conditions.count
      count = 0 
      unlock_conditions.each do |condition|
        if condition.is_complete?(student)
          count += 1
        end 
      end
      if goal == count 
        if unlock_states.where(:student_id => student.id).present?
          unlock_states.where(:student_id => student.id).first.unlocked = true 
        else
          self.unlock_states.create(:student_id => student.id, :unlocked => true, :unlockable_id => self.id, :unlockable_type => "Assignment")
        end
      else
        return false
      end
    end
  end

  def visible_for_student?(student)
    if is_unlockable?
      if visible_when_locked? || is_unlocked_for_student?(student)
        return true
      end
    else
      if visible?
        return true
      end
    end
  end


  #badges per role
  def earned_badges_by_student_id
    @earned_badges_by_student_id ||= earned_badges.group_by { |eb| [eb.student_id] }
  end

  def earned_badge_for_student(student)
    earned_badges_by_student_id[[student.id]].try(:first)
  end

  def earned_badges_for_student(student)
    earned_badges.where(:student_id => student)
  end

  def find_or_create_predicted_earned_badge(student)
    PredictedEarnedBadge.where(student: student, badge: self).first || PredictedEarnedBadge.create(student_id: student.id, badge_id: self.id)
  end

  #Counting how many times a particular student has earned this badge
  def earned_badge_count_for_student(student)
     earned_badges.where(:student_id => student, :student_visible => true).count
  end

  def earned_badge_total_points(student)
    earned_badges.where(:student_id => student, :student_visible => true).pluck('score').sum
  end

end
