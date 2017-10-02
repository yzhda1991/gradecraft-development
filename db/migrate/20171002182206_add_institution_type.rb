class AddInstitutionType < ActiveRecord::Migration[5.0]
  def change
    add_column :institutions, :institution_type, :string, null: true
  end
end
