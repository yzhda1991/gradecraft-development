class AddPseudyonymToCourseMembership < ActiveRecord::Migration[5.0]
  def change
    add_column :course_memberships, :pseudonym, :string
  end
end
