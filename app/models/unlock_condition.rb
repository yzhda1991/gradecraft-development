class UnlockCondition < ActiveRecord::Base

	attr_accessible :unlockable_id, :unlockable_type, :condition_id, :condition_type,
	:condition_state, :condition_value, :condition_date

	belongs_to :unlockable, :polymorphic => true
	belongs_to :condition, :polymorphic => true

	#validates_presence_of :unlockable_id, :unlockable_type, :condition_id, :condition_type, :condition_state

	def name
		if condition_type == "Badge"
			badge = Badge.find(condition_id)
			return badge.name
		elsif condition_type == "Assignment"
			assignment = Assignment.find(condition_id)
			return assignment.name
		end
	end

	def is_complete?(student)
		if condition_type == "Badge"
			badge = student.earned_badge_for_badge(condition_id)
			badge_count = student.earned_badges_for_badge_count(condition_id)
			if condition_state? && condition_value? && condition_date?
				if badge.present? && (badge_count >= condition_value) &&
					student.earned_badges.where(:badge_id => condition_id).last.created_at < condition_date
						return true
				else
					return false
				end
			elsif condition_state? && condition_value?
				if badge.present? &&
					badge_count >= condition_value
					return true
				else
					return false
				end
			elsif condition_state?
				if student.earned_badge_for_badge(condition_id).present?
					return true
				else
					return false
				end
			end
		elsif condition_type == "Assignment"
			if condition_state == "Submitted"
				assignment = Assignment.find(condition_id)
				submission = student.submission_for_assignment(assignment)
				if condition_date?
					if submission.present? && (submission.updated_at < condition_date)
						return true
					else
						return false
					end
				elsif submission.present?
					return true
				else
					return false
				end
			elsif condition_state == "Grade Earned"
				grade = student.grade_for_assignment_id(condition_id).first
				if condition_value? && condition_date?
					if (grade.score > condition_value) && (grade.updated_at < condition_date)
						return true
					else
						return false
					end
				elsif condition_value?
					if grade.score > condition_value
						return true
					else
						return false
					end
				elsif condition_date?
					if grade.updated_at < condition_date
						return true
					else
						return false
					end
				elsif grade.present?
						return true
				else
					return false
				end
			end
		end
	end
end
