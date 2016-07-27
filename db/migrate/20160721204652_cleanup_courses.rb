class CleanupCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :group_setting
    remove_column :courses, :predictor_setting
    remove_column :courses, :academic_history_visible
    remove_column :courses, :max_group_size
    remove_column :courses, :min_group_size
    remove_column :courses, :media
    remove_column :courses, :media_credit
    remove_column :courses, :media_caption

    change_column :courses, :name, :string, null: false
    change_column :courses, :created_at, :datetime, null: false
    change_column :courses, :updated_at, :datetime, null: false
    rename_column :courses, :courseno, :course_number
    change_column :courses, :course_number, :string, null: false

    rename_column :courses, :user_term, :student_term
    change_column :courses, :student_term, :string, default: "Student", null: false
    change_column :courses, :team_term, :string, default: "Team", null: false
    change_column :courses, :team_leader_term, :string, default: "TA", null: false
    change_column :courses, :group_term, :string, default: "Group", null: false
    change_column :courses, :weight_term, :string, default: "Multiplier", null: false
    change_column :courses, :badge_term, :string, default: "Badge", null: false
    change_column :courses, :assignment_term, :string, default: "Assignment", null: false
    change_column :courses, :challenge_term, :string, default: "Challenge", null: false
    change_column :courses, :pass_term, :string, default: "Pass", null: false
    change_column :courses, :fail_term, :string, default: "Fail", null: false

    rename_column :courses, :homepage_message, :course_rules
    change_column :courses, :course_rules, :text
    rename_column :courses, :grading_philosophy, :gameful_philosophy
    change_column :courses, :gameful_philosophy, :text

    change_column :courses, :status, :boolean, default: true, null: false
    rename_column :courses, :team_roles, :has_team_roles
    change_column :courses, :has_team_roles, :boolean, default: false, null: false
    rename_column :courses, :badge_setting, :has_badges
    change_column :courses, :has_badges, :boolean, default: false, null: false
    rename_column :courses, :team_setting, :has_teams
    change_column :courses, :has_teams, :boolean, default: false, null: false
    rename_column :courses, :team_challenges, :has_team_challenges
    change_column :courses, :has_team_challenges, :boolean, default: false, null: false
    rename_column :courses, :character_names, :has_character_names
    change_column :courses, :has_character_names, 'boolean USING CAST(has_character_names AS boolean)', default: false, null: false
    rename_column :courses, :character_profiles, :has_character_profiles
    change_column :courses, :has_character_profiles, :boolean, default: false, null: false
    rename_column :courses, :in_team_leaderboard, :has_in_team_leaderboards
    change_column :courses, :has_in_team_leaderboards, :boolean, default: false, null: false

    change_column :courses, :team_score_average, :boolean, default: false, null: false
    change_column :courses, :add_team_score_to_student, :boolean, default: false, null: false
    change_column :courses, :hide_analytics, :boolean, default: false, null: false

    change_column :courses, :accepts_submissions, :boolean, default: true, null: false
    change_column :courses, :teams_visible, :boolean, default: true, null: false
  end
end
