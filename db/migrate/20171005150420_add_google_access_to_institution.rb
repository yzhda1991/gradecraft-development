class AddGoogleAccessToInstitution < ActiveRecord::Migration[5.0]
  def change
    add_column :institutions, :has_google_access, :boolean, null: false, default: true
  end
end
