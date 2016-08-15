class RemoveCharacterLimits < ActiveRecord::Migration
  def change
    change_column :assignment_files, :filename, :string, limit: nil
    change_column :assignment_files, :filepath, :string, limit: nil
    change_column :assignment_files, :file, :string, limit: nil
    
    change_column :assignment_score_levels, :name, :string, limit: nil
    
    change_column :assignments, :grade_scope, :string, limit: nil
    change_column :assignments, :media, :string, limit: nil
    change_column :assignments, :thumbnail, :string, limit: nil
    change_column :assignments, :media_credit, :string, limit: nil
    change_column :assignments, :media_caption, :string, limit: nil
    change_column :assignments, :mass_grade_type, :string, limit: nil
    
    change_column :badge_files, :filename, :string, limit: nil
    change_column :badge_files, :filepath, :string, limit: nil
    change_column :badge_files, :file, :string, limit: nil
    
    change_column :badges, :icon, :string, limit: nil
    
    change_column :challenge_files, :filename, :string, limit: nil
    change_column :challenge_files, :filepath, :string, limit: nil
    change_column :challenge_files, :file, :string, limit: nil
    
    change_column :challenge_grades, :status, :string, limit: nil
    
    change_column :challenges, :media, :string, limit: nil
    change_column :challenges, :thumbnail, :string, limit: nil
    change_column :challenges, :media_credit, :string, limit: nil
    change_column :challenges, :media_caption, :string, limit: nil
    change_column :challenges, :mass_grade_type, :string, limit: nil
    
    change_column :course_memberships, :role, :string, limit: nil
    
    change_column :courses, :year, :string, limit: nil
    change_column :courses, :semester, :string, limit: nil
    change_column :courses, :tagline, :string, limit: nil
    change_column :courses, :office, :string, limit: nil
    change_column :courses, :phone, :string, limit: nil
    change_column :courses, :class_email, :string, limit: nil
    change_column :courses, :twitter_handle, :string, limit: nil
    change_column :courses, :twitter_hashtag, :string, limit: nil
    change_column :courses, :location, :string, limit: nil
    change_column :courses, :office_hours, :string, limit: nil
    change_column :courses, :lti_uid, :string, limit: nil
    
    change_column :criteria, :name, :string, limit: nil
    
    change_column :events, :name, :string, limit: nil
    change_column :events, :media_caption, :string, limit: nil
    
    change_column :grade_files, :filename, :string, limit: nil
    change_column :grade_files, :filepath, :string, limit: nil
    change_column :grade_files, :file, :string, limit: nil
    
    change_column :grade_scheme_elements, :level, :string, limit: nil
    change_column :grade_scheme_elements, :letter, :string, limit: nil
    change_column :grade_scheme_elements, :description, :string, limit: nil
    
    change_column :grades, :type, :string, limit: nil
    change_column :grades, :status, :string, limit: nil
    change_column :grades, :group_type, :string, limit: nil
    
    change_column :group_memberships, :accepted, :string, limit: nil
    change_column :group_memberships, :group_type, :string, limit: nil
    
    change_column :groups, :name, :string, limit: nil
    change_column :groups, :approved, :string, limit: nil
    
    change_column :levels, :name, :string, limit: nil
    
    change_column :lti_providers, :name, :string, limit: nil
    change_column :lti_providers, :uid, :string, limit: nil
    change_column :lti_providers, :consumer_key, :string, limit: nil
    change_column :lti_providers, :consumer_secret, :string, limit: nil
    change_column :lti_providers, :launch_url, :string, limit: nil
    
    change_column :proposals, :title, :string, limit: nil
    
    change_column :sessions, :session_id, :string, limit: nil
    
    change_column :student_academic_histories, :major, :string, limit: nil
    change_column :student_academic_histories, :year_in_school, :string, limit: nil
    change_column :student_academic_histories, :state_of_residence, :string, limit: nil
    change_column :student_academic_histories, :high_school, :string, limit: nil
    
    change_column :submission_files, :filename, :string, limit: nil
    change_column :submission_files, :filepath, :string, limit: nil
    change_column :submission_files, :file, :string, limit: nil
    
    change_column :submissions, :feedback, :string, limit: nil
    change_column :submissions, :comment, :string, limit: nil
    change_column :submissions, :link, :string, limit: nil
    change_column :submissions, :assignment_type, :string, limit: nil
    
    drop_table :tasks
    
    change_column :teams, :name, :string, limit: nil
    change_column :teams, :banner, :string, limit: nil
    
    drop_table :themes
    
    change_column :users, :username, :string, limit: nil
    change_column :users, :email, :string, limit: nil
    change_column :users, :crypted_password, :string, limit: nil
    change_column :users, :salt, :string, limit: nil
    change_column :users, :reset_password_token, :string, limit: nil
    change_column :users, :remember_me_token, :string, limit: nil
    change_column :users, :avatar_file_name, :string, limit: nil
    change_column :users, :avatar_content_type, :string, limit: nil
    change_column :users, :first_name, :string, limit: nil
    change_column :users, :last_name, :string, limit: nil
    change_column :users, :display_name, :string, limit: nil
    change_column :users, :final_grade, :string, limit: nil
    change_column :users, :team_role, :string, limit: nil
    change_column :users, :lti_uid, :string, limit: nil
    change_column :users, :last_login_from_ip_address, :string, limit: nil
    change_column :users, :kerberos_uid, :string, limit: nil
  end
end
