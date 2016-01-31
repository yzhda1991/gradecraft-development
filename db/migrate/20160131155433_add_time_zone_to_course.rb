class AddTimeZoneToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :time_zone, :string, default: "Eastern Time (US & Canada)"
  end
end
