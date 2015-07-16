class UnlockState < ActiveRecord::Base

	attr_accessible :unlockable_id, :unlockable_type, :student_id, :instructor_unlocked, :unlocked

	belongs_to :unlockable, :polymorphic => true
	belongs_to :student



end