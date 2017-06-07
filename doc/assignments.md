# Assignments

  * Is a [customizable term](customizable terms)

### Concerns
  * [AssignmentAnalytics](assignment_analytics)
  * [Copyable](copyable)
  * [Gradable](gradable)
  * [MultipleFileAttributes](multiple_file_attributes)
  * [Sanitizable](sanitizable)
  * [ScoreLevelable](score_levelable)
  * [UploadsMedia](uploads_media)
  * [UnlockableCondition](unlockable_condition)

### Associations

#### belongs_to

The `updated_at` attributes of both these models will be set to the current date when one of their assignments are saved

  * [Course](courses)
  * [Assignment Type](assignment_types)

#### has_one

  * [Rubric](rubrics) - when an Assignment is destroyed, its Rubric will be destroyed as well
  * [Imported Assignment](imported_assignment)

#### has_many

  * [Groups](groups) - through Assignment Groups
  * [Users](users) - through [Grades](grades)
  * [Assignment Weights](assignment_weights)

#### dependent: :destroy

When an Assignment is destroyed, all of the following models that belong to it will be as well.

  * [Assignment Score Levels] - ordered by the Assignment Score Level's `points` attribute
  * [Weights] `weights`, however actual class name is "AssignmentWeight"
  * [Assignment Groups]
  * [Unlock Conditions] - polymorphic relationship. Assignments are referred to as `unlockable` in Unlock Condition model
  * [Unlock Keys] - accessed with `unlock_keys`, however actual class name is "UnlockCondition"
  * [Unlock States] - polymorphic relationship. Assignments are referred to as `unlockable` in Unlock State model
  * [Submissions](submissions)
  * [Rubric Grades](rubrics)
  * [Grades](grade)
  * [Assignment Files]

### Validations

  * `open_before_close` - fails if the due and open dates are present and the open date exceeds the due date
  * `submissions_after_due` - fails if the date to no longer accepting submissions and the due date are present, and the due date exceeds the date for no longer accepting submissions
  * `submissions_after_open` - fails if the date to no longer accepting submissions and the open date are present, and the open date exceeds the date for no longer accepting submissions
  * boolean methods that must be set to either true or false: `student_logged`, `required`, `accepts_submissions`,
  `release_necessary`, `visible`, `resubmissions_allowed`, `include_in_timeline`, `include_in_predictor`, `include_in_to_do`, `use_rubric`, `accepts_attachments`, `accepts_text`, `accepts_links`, `pass_fail`, `hide_analytics`, `visible_when_locked`, `show_name_when_locked`, `show_points_when_locked`, `show_description_when_locked`, `show_purpose_when_locked`

### Callbacks

#### before_save

  * clean_html: `description` - Strips `description` attribute of html
  * clean_html: `purpose` - Strips `purpose` attribute of html
  * `zero_points_for_pass_fail` - sets the point total to 0 if the assignment is pass fail
  * `reset_default_for_nil_values`

### Scopes

  * `group_assignments`
  * `timelineable`
  * `chronological`
  * `alphabetical`
  * `ordered`
  * `with_dates`

### Attributes
  * `accepts_resubmissions_until`
  * `accepts_submissions` - boolean switch controlling whether the assignment is accepting submissions from students
  * There are three boolean attributes that control what can be submitted by the student. All three are true by default:
    * `accepts_links` - whether students may submit a link in the submission
    * `accepts_text` - whether students may submit the content/statement of their submission in text
    * `accepts_attachments` - whether students may submit an attachment file in their submission
  * `accepts_submissions_until` - the date at which submissions are no longer accepted by the assignment
  * `description` - text description of the assignment
  * `due_at` - time when the assignment is officially due at, though students can still submit assignments in some cases
  * `full_points` - amount of points that is considered to be a perfect grade. Unlike `max_points` in the assignment type model, students can still earn above this
  * `grade_scope` - kind of assignment being graded. The three values are "Individual", "Group" and "Team". Defaults to "Individual"
  * `grading_due_at`
  * `hide_analytics` - boolean switch controlling whether the assignment's analytics should be hidden from students. The course model's `hide_analytics` attribute must be false for the checkbox to appear in the assignment form view
  * `include_in_predictor` - boolean switch controlling whether the assignment can be seen by students in the grade predictor. Defaults to true
  * `include_in_to_do` - boolean switch controlling whether students can see the assignment in the syllabus' todo sidebar ("Due This Week" in the view). Defaults to true
  * `include_in_timeline` - boolean switch controlling whether the assignment will be included in the class' syllabus. If `open_at` or `due_at` is false, the assignment will not appear in the timeline, regardless of whether this is true. Defaults to true
  * `max_submissions`
  * `name` - name of assignment, required attribute
  * `notify_released` - whether a student should be notified by email when a grade is awarded. Defaults to true
  * `open_at` - time when students can begin submitting their assignments
  * `pass_fail` - boolean switch controlling whether the assignment is simply pass or fail
  * `purpose` - purpose of the assignment. Found under the "Description & Downloads" tab in the assignment page
  * `release_necessary` - boolean switch controlling whether a grade's status must be "Released" for a student to see their grade. Defaults to false. See [[grade status]] for more information
  * `required` - boolean switch controlling whether the assignment is required for students to complete the course
  * `resubmissions_allowed` - boolean switch controlling whether students can resubmit their Assignment
  * `show_name_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's name in the syllabus
  * `show_points_when_locked` - when both this and `visible_when_locked` are true, in the syllabus students will see the number of points possible to earn in the locked assignment, and their grade score if it has been released
  * `show_description_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's description in its show page
  * `show_purpose_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's purpose in the "Description & Downloads" tab of the show page
  * `student_logged` - boolean switch controlling whether students can log grades themselves. When a student's grade is logged, the grade model's `raw_points` is set to the point total and its `status` is set to "Graded"
  * `threshold_points` - minimum amount of points students must receive to earn points for the assignment. If the threshold is not met, the student will earn 0 points for the assignment. Implemented in the grade model's method `calculate_final_points`
  * `use_rubric` - boolean switch controlling whether instructors must grade students using a rubric as opposed to quick grading. Instructors may still create a rubric regardless of this value. Defaults to true
  * `visible` - whether the assignment is visible to students. If true, an assignment functions as you'd normally expect. If false, the assignment will be invisible to a student until they have been graded by their instructor. Defaults to true
  * `visible_when_locked` - boolean switch controlling whether the assignment will be visible when it is locked

### Instance Methods

  * `copy(attributes={})` - creates a duplicate of the assignment, prepends it with "Copy of ", copies the values of the attributes from the `attributes` optional hash, and copies the assignment's rubric and score levels
  * `to_json(options = {})` - passes in the options to the super class' `to_json`, only rendering the `id` attribute
  * `visible_for_student?(student)` - true when either of these conditions are met:
    * assignment is visible when locked, or is already unlocked
    * `visible` is set to true
  * `full_points_for_student(student, weight = nil)` - returns `full_points` multiplied by the assignment type's weight for the student

#### Submissions

*Assignments control how and when students can create Submissions*

  * `soon?` - returns true when the due date is present, has not passed and is less than 7 days away
  * `future?` - returns true if the due date is present and has not passed
  * `opened?` - returns true when the open date does not exist or has passed
  * `overdue?` - returns true when the due date is present and has passed
  * `accepting_submissions?` - returns true when the date to stop accepting submissions has not passed or does not exist
  * `submissions_have_closed?` - returns true when the date to stop accepting submissions exists and has passed
  * `open?` - returns true when both of the following conditions are met:
    * open date does not exist or has passed
    * assignment is either not overdue (due date either does not exist or has not passed), or still accepting submissions regardless (date to stop accepting submissions either does not exist or has not yet passed)

#### Student Submission Queries

*All methods beginning with "student_submissions" are essentially the `student_submissions` method with added `where` clauses*

  * `student_submissions` - returns all of the submissions for the assignment in the form of an array, eager loading the submission's students and submission files
  * `student_submissions_for_team(team)` - submissions that have been submitted by students from the passed in team
  * `student_submissions_with_files` - submissions that contain text, a link, or a file
  * `student_submissions_with_files_for_team(team)` - combines `student_submissions_for_team(team)` and `student_submissions_with_files`
  * `student_with_submissions_query` - returns an SQL string that selects the IDs of all students who made a submission for an assignment (the assignment is passed in through the question mark)
  * `submissions_with_files_query` - returns an SQL string for use in a where clause. Finds all submissions that contain text, a link, or a file
  * `present_submission_files_query` - returns an SQL string selecting all submissions with one or more files. Used in `submissions_with_files_query`
  * `missing_submission_files_query` - returns an SQL string selecting all submissions that have a file that is either missing or present, depending on what replaces the question mark (true for missing)
  * `students_with_submissions` - returns all users who made a submission for the assignment
  * `students_with_submissions_on_team(team)` - returns all users that have made a submission for the assignment and are in the passed in team
  * `students_with_text_or_binary_files` - returns all users who made a submission to the assignment containing text, a link or a file
  * `students_with_text_or_binary_files_on_team(team)` - same as `students_with_text_or_binary_files`, but with the added requirement that the users be from the passed in team
  * `students_with_missing_binaries` - returns all users whose submissions for the assignment have a missing file
  * `students_with_missing_binaries_on_team(team)` - same as `students_with_missing_binaries`, but with the added requirement that the users be from the passed in team

#### Grades

*Students receive a Grade for each Assignment that they complete*

  * `is_individual?` - returns true if the grade scope is set to "Individual"
  * `has_groups?` - returns true if the grade scope is set to "Group"

#### Unlocks

  * `is_unlockable?` - true if the assignment has unlock conditions
  * `is_a_condition?` - true if the assignment has unlock conditions
  * `unlockable` - returns the unlockable object that the assignment is used to unlock
  * `is_unlocked_for_student?(student)` - true when either the assignment is unlocked for the student or no unlock conditions are present
  * `check_unlock_status(student)` - checks to see if all unlock conditions have been completed: if so, the assignment's unlock state for the student is set to unlocked
  * `find_or_create_unlock_state(student)` - finds the assignment's unlock state for the student, creating it if it does not already exist

#### Assignment Score Levels

  * `has_levels?` - returns true if assignment score levels are present
  * `grade_level(grade)` - returns name of the assignment score level that was used to grade the student
  * `score_levels_set` - returns assignment score levels if they are present

#### Assignment Weights

  * `weight_for_student(student, weight = nil)` - if the weight is greater than 0, then it's returned (set to the student's weight if nothing was passed in). Otherwise, returns the default weight
  * `default_weight` - returns the course's default assignment weight. This will be multiplied by assignments that are not weighted

#### CSV

Each method returns a CSV string and has an optional argument `optional` that can be passed into `CSV.generate`. Each row corresponds to a student enrolled in the assignment's course.

  * `gradebook_for_assignment` - "Score", "Raw Points", "Feedback" and "Last Updated" will be left out of a row if its student has not been given a grade. Columns:
    * "First Name", "Last Name", "Uniqname", "Score", "Raw Points", "Statement", "Feedback", "Last Updated"
  * `email_based_grade_import` - "Score" and "Feedback" will be left out of a row if its student has not been given a grade. Columns:
    * "First Name", "Last Name", "Email", "Score", "Feedback"
  * `username_based_grade_import` - same as `email_based_grade_import`, except instead of the "Email" column, it has the "Username" column

#### Predictor

  * there are three methods returning true depending on what the points predictor display is set to:
    * `fixed?` - "Fixed"
    * `slider?` - "Slider"
    * `select?` - "Select List"
  * `predictor_display_type` - returns a string based on the following conditions:
    * points predictor display is set to fixed or the assignment is "pass or fail", in which case "checkbox" is returned
    * points predictor display is set to slider, in which case "slider" is returned
    * neither of the above two conditions are met, in which case "slider" is returned as default

#### Rubrics

  * `grade_with_rubric?` - returns true when rubrics are enabled for the assignment, the rubric is present, and the rubric has at least one criteria
  * `find_or_create_rubric` - returns the rubric, creating it if it does not already exist
