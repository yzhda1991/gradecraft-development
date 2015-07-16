class AddUnlocks < ActiveRecord::Migration
  def change

  	add_column :assignments, :visible_when_locked, :boolean, :default => true
  	add_column :badges, :visible_when_locked, :boolean, :default => true

  	create_table :unlock_conditions do |t|
  		t.integer :unlockable_id
  		t.string :unlockable_type 
  		t.integer :condition_id
  		t.string :condition_type 
  		t.string :condition_state
  		t.integer :condition_value 
  		t.datetime :condition_date
  	end

  	create_table :unlock_states do |t|
  		t.integer :unlockable_id
  		t.string :unlockable_type 
  		t.integer :student_id
  		t.boolean :unlocked 
  		t.boolean :instructor_unlocked
  	end

  end
end
