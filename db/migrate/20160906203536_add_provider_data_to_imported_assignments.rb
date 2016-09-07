class AddProviderDataToImportedAssignments < ActiveRecord::Migration
  def change
    add_column :imported_assignments, :provider_data, :hstore
  end
end
