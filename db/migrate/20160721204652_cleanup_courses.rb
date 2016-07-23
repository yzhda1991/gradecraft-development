class CleanupCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :group_setting
    remove_column :courses, :predictor_setting

    change_column :courses, :name, :string, null: false
    change_column :courses, :created_at, :datetime, null: false
    change_column :courses, :updated_at, :datetime, null: false
    rename_column :courses, :courseno, :course_number, :string, null: false
    rename_column :courses, :badge_setting, :has_badges, :string, null: false
    rename_column :courses, :team_setting, :has_teams, :string, null: false


    # t.string   "year",                            limit: 255
    # t.string   "semester",                        limit: 255
    # t.string   "user_term",                       limit: 255
    # t.string   "team_term",                       limit: 255
    # t.string   "homepage_message",                limit: 255
    # t.boolean  "status",                                                              default: true
    # t.datetime "weights_close_at"
    # t.boolean  "team_roles"
    # t.string   "team_leader_term",                limit: 255
    # t.string   "group_term",                      limit: 255
    # t.boolean  "accepts_submissions"
    # t.boolean  "teams_visible"
    # t.string   "weight_term",                     limit: 255
    # t.integer  "max_group_size"
    # t.integer  "min_group_size"
    # t.decimal  "default_weight",                              precision: 4, scale: 1, default: 1.0
    # t.string   "tagline",                         limit: 255
    # t.boolean  "academic_history_visible"
    # t.string   "office",                          limit: 255
    # t.string   "phone",                           limit: 255
    # t.string   "class_email",                     limit: 255
    # t.string   "twitter_handle",                  limit: 255
    # t.string   "twitter_hashtag",                 limit: 255
    # t.string   "location",                        limit: 255
    # t.string   "office_hours",                    limit: 255
    # t.text     "meeting_times"
    # t.string   "media",                           limit: 255
    # t.string   "media_credit",                    limit: 255
    # t.string   "media_caption",                   limit: 255
    # t.string   "badge_term",                      limit: 255
    # t.string   "assignment_term",                 limit: 255
    # t.string   "challenge_term",                  limit: 255
    # t.text     "grading_philosophy"
    # t.integer  "total_weights"
    # t.integer  "max_weights_per_assignment_type"
    # t.boolean  "character_profiles"
    # t.string   "lti_uid",                         limit: 255
    # t.boolean  "team_score_average"
    # t.boolean  "team_challenges"
    # t.integer  "max_assignment_types_weighted"
    # t.integer  "full_points"
    # t.boolean  "in_team_leaderboard"
    # t.boolean  "add_team_score_to_student",                                           default: false
    # t.datetime "start_date"
    # t.datetime "end_date"
    # t.string   "pass_term",                       limit: 255
    # t.string   "fail_term",                       limit: 255
    # t.string   "syllabus"
    # t.boolean  "hide_analytics"
    # t.string   "character_names"
    # t.string   "time_zone",
  end
end
