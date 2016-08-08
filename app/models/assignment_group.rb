class AssignmentGroup < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :group

  validates_uniqueness_of :assignment_id, { scope: :group_id }

  validates_presence_of :assignment_id
  validates_presence_of :group

end
