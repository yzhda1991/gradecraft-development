class CleanUpChallengeModel < ActiveRecord::Migration
  def change
    remove_column :challenges, :levels
    remove_column :challenges, :mass_grade
  end
end
