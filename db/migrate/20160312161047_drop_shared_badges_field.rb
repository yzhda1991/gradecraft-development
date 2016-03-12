class DropSharedBadgesField < ActiveRecord::Migration
  def change
    remove_column :course_memberships, :shared_badges
  end
end
