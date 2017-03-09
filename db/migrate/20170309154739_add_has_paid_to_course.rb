class AddHasPaidToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :has_paid, :boolean, default: true, null: false
  end
end
