class TransferRoleToCourseMemberships < ActiveRecord::Migration

  def up
    User.all.each do |u|
      u.course_memberships.to_a.each {|cm| cm.update_attribute(:role, u.role)}
    end
  end

  def down
    User.all.each do |u|
      unless u.course_memberships.empty?
        course_id = u.current_course_id || u.courses.first.id
        u.update_attribute(:role, u.course_memberships.where(course_id: course_id).first.role)
      end
    end
  end
end
