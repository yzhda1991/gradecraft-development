class ChangeReleaseNecessaryForAssignments < ActiveRecord::Migration[5.0]
  def change
    change_column :assignments, :release_necessary, :boolean, default: true, null: false
  end
end
