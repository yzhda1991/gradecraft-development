class AddDefaultPointsToBadge < ActiveRecord::Migration
  def up
    change_column :badges, :full_points, :integer, :default => 0
    Badge.where("full_points IS NULL").update_all("full_points=0")
  end

  def down
    change_column :badges, :full_points, :integer, :default => nil
  end
end


