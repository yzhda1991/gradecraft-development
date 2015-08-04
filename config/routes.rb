GradeCraft::Application.routes.draw do

  mount RailsEmailPreview::Engine, at: 'emails' if Rails.env.development?

  require 'admin_constraint'

  #1. Analytics & Charts
  #2. Announcements
  #3. Assignments, Submissions, Tasks, Grades
  #4. Assignment Types
  #5. Assignment Type Weights
  #6. Badges
  #7. Challenges
  #8. Courses
  #9. Groups
  #10. Informational Pages
  #11. Rubrics & Grade Schemes
  #12. Teams
  #13. Users
  #14. User Auth
  #15. Uploads
  #16. Events
  #17. Predictor

  #1. Analytics & Charts
  namespace :analytics do
    root action: :index
    get :staff
    get :students
    get :top_10
    get :per_assign
    get :all_events
    get :role_events
    get :assignment_events
    get :login_frequencies
    get :role_login_frequencies
    get :login_events
    get :login_role_events
    get :all_pageview_events
    get :all_role_pageview_events
    get :all_user_pageview_events
    get :pageview_events
    get :role_pageview_events
    get :user_pageview_events
    get :prediction_averages
    get :assignment_prediction_averages
    get :export
  end

  post 'analytics_events/predictor_event'
  post 'analytics_events/tab_select_event'

  #2. Announcements
  resources :announcements, except: [:destroy, :edit, :update]

  #3. Assignments, Submissions, Tasks, Grades
  resources :assignments do
    collection do
      post :sort
      get :feed
      get :settings
      post 'copy' => 'assignments#copy'
      get 'weights' => 'assignment_weights#mass_edit', :as => :mass_edit_weights
    end
    member do
      get 'mass_grade' => 'grades#mass_edit', as: :mass_grade
      put 'mass_grade' => 'grades#mass_update'
      get 'group_grade' => 'grades#group_edit', as: :group_grade
      put 'group_grade' => 'grades#group_update'
      get 'export_grades'
      get 'export_submissions'
      get 'email_based_grade_import' => 'assignments#email_based_grade_import'
      get 'username_based_grade_import' => 'assignments#username_based_grade_import'
      get 'name_based_grade_import' => 'assignments#name_based_grade_import'
      get 'rubric_grades_review'
      put :update_rubrics
      scope 'grades', as: :grades, controller: :grades do
        post :edit_status
        put :update_status
        get :import
        post :email_import
        post :username_import
        post :name_import
        post :self_log
        post :predict_score
        post :feedback_read
        get :remove
      end
    end
    resources :submissions do
      post :upload
    end
    resources :tasks
    resource :grade, only: [:show, :edit, :update, :destroy] do
      put :submit_rubric, on: :collection
      resources :earned_badges
    end
    resource :rubric do
      get :existing_metrics
      get :course_badges
      resources :metrics
      get :design, on: :collection
    end
  end
  resources :unlock_states do
    member do
      post :manually_unlock
    end
  end
  resources :unlock_conditions

  # earned badges grade routes
  put "grades/:id/async_update", to: "grades#async_update"
  post "grades/earn_student_badge", to: "grades#earn_student_badge"
  delete "grade/:grade_id/student/:student_id/badge/:badge_id/earned_badge/:id", to: "grades#delete_earned_badge"
  delete "grade/:grade_id/earned_badges", to: "grades#delete_all_earned_badges"

  resources :metrics do
    put :update_order, on: :collection
  end

  resources :tiers
  resources :graded_metrics
  resources :metric_badges

  resources :tier_badges

  #4. Assignment Types
  resources :assignment_types do
    member do
      get 'all_grades'
      get 'export_scores'
    end
    collection do
      post :sort
      get 'export_all_scores'
    end
  end

  #5. Assignment Type Weights
  get 'assignment_type_weights' => 'assignment_type_weights#mass_edit', as: :assignment_type_weights
  put 'assignment_type_weights' => 'assignment_type_weights#mass_update'
  post 'assignment_type_weight' => 'assignment_type_weights#update'

  resources :assignment_weights

  #6. Badges
  resources :badges do
    post :predict_times_earned
    resources :tasks
    resources :earned_badges do
      collection do
        get :chart
      end
    end
    member do
      get 'mass_award' => 'earned_badges#mass_edit', as: :mass_award
      put 'mass_award' => 'earned_badges#mass_update'
    end
    collection do
      post :sort
    end
  end

  #7. Challenges
  resources :challenges do
    post :predict_points
    resources :challenge_grades do
      collection do
        post :edit_status
        put :update_status
        get :mass_edit

      end
    end
    member do
      get 'mass_edit' => 'challenge_grades#mass_edit', as: :mass_edit
      put 'mass_edit' => 'challenge_grades#mass_update'
    end
    resources :challenge_files do
      get :remove
    end
  end

  #8. Courses
  resources :courses do
    collection do
      post 'copy' => 'courses#copy'
    end
    member do
      get 'timeline_settings' => 'courses#timeline_settings'
      put 'timeline_settings' => 'courses#timeline_settings_update'
      get 'predictor_settings' => 'courses#predictor_settings', as: :predictor_settings
      put 'predictor_settings' => 'courses#predictor_settings_update'
      get 'predictor_preview' => 'courses#predictor_preview'
    end
  end
  resources :course_memberships

  post '/current_course/change' => 'current_courses#change', :as => :change_current_course
  get 'current_course' => 'current_courses#show'

  get 'leaderboard' => 'students#leaderboard'
  get 'multiplier_choices' => 'info#choices'
  get 'earned_badges' => 'info#awarded_badges'
  get 'grading_status' => 'info#grading_status'
  get 'resubmissions' => 'info#resubmissions'
  get 'ungraded_submissions' => 'info#ungraded_submissions'
  get 'gradebook' => 'info#gradebook'
  get 'final_grades' => 'info#final_grades'
  get 'research_gradebook' => 'info#research_gradebook'
  get 'export_earned_badges' => 'courses#export_earned_badges'

  #9. Groups
  resources :groups do
    collection do
      get :review
    end
    resources :proposals
  end
  resources :group_memberships

  #10. Informational Pages
  namespace :info do
    get :all_grades
    get :choices
    get :awarded_badges
    get :dashboard
    get :grading_status
    get :timeline_events
    get :resubmissions
  end

  resources :home

  get 'using_gradecraft' => 'pages#using_gradecraft'
  get 'contact' => 'pages#contact'
  get 'features' => 'pages#features'
  get 'ping' => 'pages#ping'

  #11. Rubrics & Grade Schemes
  resources :rubrics

  #11. Rubrics & Grade Schemes
  resources :grade_scheme_elements do
    collection do
      post :destroy_multiple
      get 'mass_edit' => 'grade_scheme_elements#mass_edit', as: :mass_edit
      put 'mass_edit' => 'grade_scheme_elements#mass_update'
    end
  end

  #12. Teams
  resources :teams do
    collection do
      get :activity
    end
    resources :earned_badges
  end

  get 'home/index'
  get 'dashboard' => 'info#dashboard'
  get 'color_theme' => 'home#color_theme'
  root :to => "home#index"

  #13. Users
  %w{students gsis professors admins}.each do |role|
    get "users/#{role}/new" => 'users#new', :as => "new_#{role.singularize}", :role => role.singularize
  end

  resources :users do
    get :activate, on: :member
    post :activate, on: :member, action: :activated
    collection do
      get :edit_profile
      put :update_profile
      get :import
      post :upload
    end
  end
  resources :students do
    get :grade_index
    get :timeline
    get :syllabus
    get :badges
    get :predictor
    get :course_progress
    get :teams
    get :recalculate
    collection do
      get :leaderboard
      get :choices
      get :autocomplete_student_name
      get :scores_for_current_course
      get :scores_by_assignment
      get :scores_by_team
      get :scores_for_single_assignment
      get :final_grades
      get :class_badges
    end
  end
  resources :staff, only: [:index, :show]
  resources :user_sessions
  resources :passwords, path_names: { new: 'reset' }, except: [:destroy, :index]
  resources :student_academic_histories

  get 'calendar' => 'students#calendar'
  get 'timeline' => 'students#timeline'
  get 'badges' => 'students#badges'
  get 'calendar' => 'students#calendar'
  get 'syllabus' => 'students#syllabus'
  get 'course_progress' => 'students#course_progress'
  get 'my_badges' => 'students#badges'
  get 'my_team' => 'students#teams'

  #14. User Auth
  post 'auth/kerberos/callback', to: 'user_sessions#kerberos_create', as: :auth_kerberos_callback
  match 'auth/lti/callback', to: 'user_sessions#lti_create', via: [:get, :post]
  get 'auth/failure' => 'pages#auth_failure', as: :auth_failure

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  get 'reset' => 'user_sessions#new'


  get 'lti/:provider/launch', to: 'lti#launch', :as => :launch_lti_provider

  # get 'cosign_test' => 'info#cosign_test'

  #15. Uploads
  resource :uploads do
    get :remove
    get :remove_submission_file
  end

  #16. Events
  resources :events


  #16. Predictor, Student View
  get 'gse_mass_edit' => 'grade_scheme_elements#mass_edit', defaults: {format: :json}
  get 'predictor' => 'students#predictor'
  get 'predictor_grade_levels' => 'grade_scheme_elements#student_predictor_data', defaults: {format: :json}
  get 'predictor_assignment_types' => 'assignment_types#student_predictor_data', defaults: {format: :json}
  get 'predictor_assignments' => 'assignments#student_predictor_data', defaults: {format: :json}
  get 'predictor_badges' => 'badges#student_predictor_data', defaults: {format: :json}
  get 'predictor_challenges' => 'challenges#student_predictor_data', defaults: {format: :json}
  get 'predictor_weights' => 'assignment_type_weights#student_predictor_data', defaults: {format: :json}

  #17b. Predictor, Instructor View
  get 'students/:id/predictor_grade_levels' => 'grade_scheme_elements#student_predictor_data', defaults: {format: :json}
  get 'students/:id/predictor_assignment_types' => 'assignment_types#student_predictor_data', defaults: {format: :json}
  get 'students/:id/predictor_assignments' => 'assignments#staff_predictor_data', defaults: {format: :json}
  get 'students/:id/predictor_badges' => 'badges#staff_predictor_data', defaults: {format: :json}
  get 'students/:id/predictor_challenges' => 'challenges#student_predictor_data', defaults: {format: :json}
  get 'students/:id/predictor_weights' => 'assignment_type_weights#student_predictor_data', defaults: {format: :json}

end
