class AddStudentAwardableToBadge < ActiveRecord::Migration
  def change
    add_column :badges, :student_awardable, :boolean, null: false, default: false
  end
end
