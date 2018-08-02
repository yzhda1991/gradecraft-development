class UnlockState < ApplicationRecord
  belongs_to :unlockable, polymorphic: true
  belongs_to :student, class_name: "User"

  def is_unlocked?
    unlocked? || instructor_unlocked?
  end
end
