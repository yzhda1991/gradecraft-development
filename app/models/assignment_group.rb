class AssignmentGroup < ApplicationRecord
  belongs_to :assignment
  belongs_to :group

  validates_presence_of :assignment
  validates_presence_of :group
  validates_uniqueness_of :assignment_id, { scope: :group_id }
end
