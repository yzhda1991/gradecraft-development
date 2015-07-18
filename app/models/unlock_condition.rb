class UnlockCondition < ActiveRecord::Base

	attr_accessible :unlockable_id, :unlockable_type, :condition_id, :condition_type, 
	:condition_state, :condition_value, :condition_date

	belongs_to :unlockable, :polymorphic => true
	belongs_to :condition, :polymorphic => true

	validates_presence_of :unlockable_id, :unlockable_type, :condition_id, :condition_type, :condition_state

end