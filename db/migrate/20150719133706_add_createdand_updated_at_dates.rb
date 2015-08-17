class AddCreatedandUpdatedAtDates < ActiveRecord::Migration
  def change
  	add_column :unlock_states, :created_at, :datetime
  	add_column :unlock_states, :updated_at, :datetime
  	add_column :unlock_conditions, :created_at, :datetime
  	add_column :unlock_conditions, :updated_at, :datetime
  end
end
