class AddLastImportedAtToImportedAssignments < ActiveRecord::Migration
  def change
    add_column :imported_assignments, :last_imported_at, :datetime
  end
end
