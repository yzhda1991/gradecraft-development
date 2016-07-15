class ImportedAssignment < ActiveRecord::Base
  belongs_to :assignment

  attr_accessible :assignment_id, :provider, :provider_id
end
