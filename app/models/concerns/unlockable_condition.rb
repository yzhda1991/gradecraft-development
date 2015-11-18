module UnlockableCondition
  extend ActiveSupport::Concern

  included do
    attr_accessible :unlock_conditions, :unlock_conditions_attributes

    has_many :unlock_conditions, as: :unlockable, dependent: :destroy
    has_many :unlock_keys, class_name: "UnlockCondition",
      foreign_key: :condition_id, :dependent => :destroy
    has_many :unlock_states, as: :unlockable, dependent: :destroy

    accepts_nested_attributes_for :unlock_conditions, allow_destroy: true,
      reject_if: proc { |uc| uc.condition_type.blank? || uc.condition_id.blank? }
  end

  def unlockable
    UnlockCondition.where(condition_id: self.id, condition_type: self.class.name)
      .first.unlockable
  end
end
