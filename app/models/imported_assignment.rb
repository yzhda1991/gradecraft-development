class ImportedAssignment < ActiveRecord::Base
  belongs_to :assignment

  attr_accessible :assignment_id, :provider, :provider_resource_id
end
