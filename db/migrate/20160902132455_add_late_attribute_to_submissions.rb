class AddLateAttributeToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :late, :boolean, null: false, default: false
  end
end
