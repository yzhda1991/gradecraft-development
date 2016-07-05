class AddNotNullToAssignmentFields < ActiveRecord::Migration
  def change
    change_column :assignments, :name, :string, null: false
    change_column :assignments, :created_at, :datetime, null: false
    change_column :assignments, :updated_at, :datetime, null: false
    change_column :assignments, :course_id, :integer, null: false
    change_column :assignments, :assignment_type_id, :integer, null: false
    change_column :assignments, :required, :boolean, default: false, null: false
    change_column :assignments, :accepts_submissions, :boolean, default: false, null: false
    change_column :assignments, :student_logged, :boolean, default: false, null: false
    change_column :assignments, :visible, :boolean, null: false
    change_column :assignments, :resubmissions_allowed, :boolean, default: false, null: false
    change_column :assignments, :include_in_timeline, :boolean, null: false
    change_column :assignments, :include_in_predictor, :boolean, null: false
    change_column :assignments, :include_in_to_do, :boolean, null: false
    change_column :assignments, :use_rubric, :boolean, null: false
    change_column :assignments, :accepts_attachments, :boolean, null: false
    change_column :assignments, :accepts_text, :boolean, null: false
    change_column :assignments, :accepts_links, :boolean, null: false
    change_column :assignments, :pass_fail, :boolean, null: false
    change_column :assignments, :hide_analytics, :boolean, default: false, null: false
    change_column :assignments, :visible_when_locked, :boolean, null: false
    change_column :assignments, :show_name_when_locked, :boolean, default: false, null: false
    change_column :assignments, :show_points_when_locked, :boolean, default: false, null: false
    change_column :assignments, :show_description_when_locked, :boolean, default: false, null: false
    change_column :assignments, :threshold_points, :integer, null: false
    change_column :assignments, :show_purpose_when_locked, :boolean, null: false
  end
end
