class AddPublicBadgeSettingtoCourses < ActiveRecord::Migration
  def change
    add_column :courses, :has_public_badges, :boolean, default: true, null: false
  end
end
