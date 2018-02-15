class AddViewedResourcesFieldToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :received_resources, :boolean, null: false, default: false
  end
end
