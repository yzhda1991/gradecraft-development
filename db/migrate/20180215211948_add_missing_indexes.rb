class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :assignment_files, :assignment_id
    add_index :assignment_groups, :assignment_id
    add_index :assignment_groups, :group_id
    add_index :assignment_score_levels, :assignment_id
    add_index :assignment_types, :course_id
    add_index :assignments, :assignment_type_id
    add_index :attachments, :file_upload_id
    add_index :attachments, :grade_id
    add_index :badge_files, :badge_id
    add_index :badges, :course_id
    add_index :challenge_files, :challenge_id
    add_index :challenge_grades, :challenge_id
    add_index :challenge_grades, :team_id
    add_index :challenge_score_levels, :challenge_id
    add_index :challenges, :course_id
    add_index :course_analytics_exports, :course_id
    add_index :course_analytics_exports, :owner_id
    add_index :course_creations, :course_id
    add_index :course_memberships, :earned_grade_scheme_element_id
    # add_index :courses, [:user_id, :user_id]
    add_index :criteria, :full_credit_level_id
    add_index :criteria, :rubric_id
    add_index :criterion_grades, :assignment_id
    add_index :criterion_grades, :level_id
    add_index :earned_badges, :awarded_by_id
    add_index :earned_badges, :course_id
    add_index :earned_badges, :student_id
    # add_index :earned_badges, :submission_id
    add_index :events, :course_id
    add_index :file_uploads, :assignment_id
    add_index :file_uploads, :course_id
    add_index :grade_scheme_elements, :course_id
    add_index :grades, :graded_by_id
    add_index :grades, :group_id
    add_index :grades, :submission_id
    # add_index :grades, :team_id
    add_index :group_memberships, :group_id
    add_index :groups, :course_id
    add_index :learning_objective_categories, :course_id
    add_index :learning_objective_levels, :objective_id
    add_index :learning_objective_links, :course_id
    add_index :learning_objective_links, :objective_id
    # add_index :learning_objective_links, [:assignment_id, :objective_id]
    add_index :learning_objective_observed_outcomes, :objective_level_id, name: "index_lo_outcomes_on_objective_level_id"
    add_index :learning_objectives, :category_id
    add_index :learning_objectives, :course_id
    add_index :level_badges, :badge_id
    add_index :level_badges, :level_id
    add_index :levels, :criterion_id
    add_index :proposals, :group_id
    add_index :rubrics, :assignment_id
    add_index :rubrics, :course_id
    add_index :submissions_exports, :assignment_id
    add_index :submissions_exports, :course_id
    add_index :submissions_exports, :professor_id
    add_index :submissions_exports, :team_id
    add_index :team_leaderships, :leader_id
    add_index :team_leaderships, :team_id
    add_index :team_memberships, :student_id
    add_index :team_memberships, :team_id
    add_index :teams, :course_id
    add_index :unlock_conditions, [:condition_id, :condition_type]
    add_index :unlock_conditions, [:unlockable_id, :unlockable_type]
    add_index :users, :current_course_id
  end
end
