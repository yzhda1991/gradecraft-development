class HasPaidFalse < ActiveRecord::Migration[5.0]
  def change
    change_column :courses, :has_paid, :boolean, default: false, null: false
  end
end
