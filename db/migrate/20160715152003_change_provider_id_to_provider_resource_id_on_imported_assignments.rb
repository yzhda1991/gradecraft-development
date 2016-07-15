class ChangeProviderIdToProviderResourceIdOnImportedAssignments < ActiveRecord::Migration
  def change
    rename_column :imported_assignments, :provider_id, :provider_resource_id
  end
end
