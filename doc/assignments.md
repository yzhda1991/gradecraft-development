# Assignments

  * Is a [[customizable term | customizable terms]]

## Assignment Model

### Included Concerns

*Excluding UnlockableCondition, which will eventually have its own page, documentation for all of the concerns listed below can be found in the [[Model Concerns]] page*

  * Copyable
  * Gradable
  * MultipleFileAttributes
  * Sanitizable
  * ScoreLevelable
  * UploadsMedia
  * UploadsThumbnails
  * UnlockableCondition

### Associations

#### belongs_to

The `updated_at` attributes of both these models will be set to the current date when one of their assignments are saved

  * [[Course | Courses]]
  * [[Assignment Type | assignment types]]

#### has_one

  * [[Rubric | rubrics]] - when an Assignment is destroyed, its Rubric will be destroyed as well

#### has_many

  * Groups - through Assignment Groups
  * [[Users]] - through [[Grades]]
  * Assignment Weights

##### :dependent => :destroy

When an Assignment is destroyed, all of the following models that belong to it will be as well.

  * Assignment Score Levels - ordered by the Assignment Score Level's `points` attribute
  * Weights - accessed with `weights`, however actual class name is "AssignmentWeight"
  * Assignment Groups
  * Tasks
  * Unlock Conditions - polymorphic relationship. Assignments are referred to as `unlockable` in Unlock Condition model
  * Unlock Keys - accessed with `unlock_keys`, however actual class name is "UnlockCondition"
  * Unlock States - polymorphic relationship. Assignments are referred to as `unlockable` in Unlock State model
  * [[Submissions]]
  * [[Rubric Grades | rubrics]]
  * [[Grades]]
  * Assignment Files

### Validation Methods

  * `open_before_close` - fails if the due and open dates are present and the open date exceeds the due date
  * `submissions_after_due` - fails if the date to no longer accepting submissions and the due date are present, and the due date exceeds the date for no longer accepting submissions
  * `submissions_after_open` - fails if the date to no longer accepting submissions and the open date are present, and the open date exceeds the date for no longer accepting submissions

### Callback Methods

#### before_save

  * `sanitize_description` - Strips `description` attribute of html
  * `zero_points_for_pass_fail` - sets the point total to 0 if the assignment is pass fail

### Miscellaneous

#### Attributes

  * `description` - description of assignment
  * `include_in_to_do` - boolean switch controlling whether students can see the assignment in the syllabus' todo sidebar ("Due This Week" in the view). Defaults to true
  * `name` - name of assignment. Must always be present
  * `full_points` - amount of points that is considered to be a perfect grade. Unlike `max_points` in the assignment type model, students can still go above it
  * `pass_fail` - boolean switch controlling whether the assignment is simply pass or fail
  * `purpose` - purpose of the assignment. Found under the "Description & Downloads" tab in the assignment page
  * `use_rubric` - boolean switch controlling whether instructors must grade students using a rubric as opposed to quick grading. Instructors may still create a rubric regardless of this value. Defaults to true
  * `hide_analytics` - boolean switch controlling whether the assignment's analytics should be hidden from students. The course model's `hide_analytics` attribute must be false for the checkbox to appear in the assignment form view
  * `threshold_points` - minimum amount of points students must receive to earn points for the assignment. If the threshold is not met, the student will earn 0 points for the assignment. Implemented in the grade model's method `calculate_final_points`

#### Instance Methods

  * `copy(attributes={})` - creates a duplicate of the assignment, prepends it with "Copy of ", copies the values of the attributes from the `attributes` optional hash, and copies the assignment's rubric and score levels
  * `to_json(options = {})` - passes in the options to the super class' `to_json`, only rendering the `id` attribute
  * `visible_for_student?(student)` - true when either of these conditions are met:
    * assignment is visible when locked, or is already unlocked
    * `visible` is set to true
  * `full_points_for_student(student, weight = nil)` - returns `full_points` multiplied by the assignment type's weight for the student

### Course

#### Attributes

  * `required` - boolean switch controlling whether the assignment is required for students to complete the course
  * `include_in_timeline` - boolean switch controlling whether the assignment will be included in the class' syllabus. If `open_at` or `due_at` is false, the assignment will not appear in the timeline, regardless of whether this is true. Defaults to true

### Submissions

  * Assignments control how and when students can create Submissions

#### Attributes

  * `open_at` - time when students can begin submitting their assignments
  * `due_at` - time when the assignment is officially due at, though students can still submit assignments in some cases
  * `accepts_submissions_until` - the date at which submissions are no longer accepted by the assignment (*see Assignment Open and Due Dates below*)
  * `accepts_submissions` - boolean switch controlling whether the assignment is accepting submissions from students
  * There are three boolean attributes that control what can be submitted by the student. All three are true by default:
    * `accepts_links` - whether students may submit a link in the submission
    * `accepts_text` - whether students may submit the content/statement of their submission in text
    * `accepts_attachments` - whether students may submit an attachment file in their submission
  * `resubmissions_allowed` - boolean switch controlling whether students can resubmit their Assignment

#### Instance Methods

  * `soon?` - returns true when the due date is present, has not passed and is less than 7 days away
  * `future?` - returns true if the due date is present and has not passed
  * `opened?` - returns true when the open date does not exist or has passed
  * `overdue?` - returns true when the due date is present and has passed
  * `accepting_submissions?` - returns true when the date to stop accepting submissions has not passed or does not exist
  * `submissions_have_closed?` - returns true when the date to stop accepting submissions exists and has passed
  * `open?` - returns true when both of the following conditions are met:
    * open date does not exist or has passed
    * assignment is either not overdue (due date either does not exist or has not passed), or still accepting submissions regardless (date to stop accepting submissions either does not exist or has not yet passed)

### Student Submission Queries

#### Instance Methods

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

### Grades

  * Students receive a Grade for each Assignment that they complete

#### Attributes

  * `grade_scope` - kind of assignment being graded. The three values are "Individual", "Group" and "Team". Defaults to "Individual"
  * `visible` - whether the assignment is visible to students. If true, an assignment functions as you'd normally expect. If false, the assignment will be invisible to a student until they have been graded by their instructor. Defaults to true
  * `release_necessary` - boolean switch controlling whether a grade's status must be "Released" for a student to see their grade. Defaults to false. See [[grade status]] for more information
  * `notify_released` - whether a student should be notified by email when a grade is awarded. Defaults to true
  * `mass_grade_type` - quick grading type when an instructor is grading all students in the assignment at once. Each student would have the quick grading type next to their name. There are four types:
    * "Checkbox" - a checkbox that, when selected, gives the student the amount of points set by `full_points` multiplied by his/her assignment weight (if he/she has one)
    * "Select List" - a dropdown list, with the items being the grade levels
    * "Radio Buttons" - each radio button is a grade level
    * "Text" - text field that accepts an integer between 0 and `full_points`
  * `include_in_predictor` - boolean switch controlling whether the assignment can be seen by students in the grade predictor. Defaults to true
  * `student_logged` - boolean switch controlling whether students can log grades themselves. When a student's grade is logged, the grade model's `raw_points` is set to the point total and its `status` is set to "Graded"

#### Instance Methods

  * `is_individual?` - returns true if the grade scope is set to "Individual"
  * `has_groups?` - returns true if the grade scope is set to "Group"
  * there are four methods returning true depending on what the mass grading type, also known as the quick grading type, is set to (*see `mass_grade_type` in attributes section under Grades below*):
    * `grade_checkboxes?` - "Checkbox"
    * `grade_select?` - "Select List". Assignment score levels must be present for this to return true
    * `grade_radio?` - "Radio Buttons". Assignment score levels must be present for this to return true
    * `grade_text?` - "Text"

### Unlocks

#### Attributes

  * `visible_when_locked` - boolean switch controlling whether the assignment will be visible when it is locked
  * `show_name_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's name in the syllabus
  * `show_points_when_locked` - when both this and `visible_when_locked` are true, in the syllabus students will see the number of points possible to earn in the locked assignment, and their grade score if it has been released
  * `show_description_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's description in its show page
  * `show_purpose_when_locked` - when both this and `visible_when_locked` are true, students will see the locked assignment's purpose in the "Description & Downloads" tab of the show page

#### Instance Methods

  * `is_unlockable?` - true if the assignment has unlock conditions
  * `is_a_condition?` - true if the assignment has unlock conditions
  * `unlockable` - returns the unlockable object that the assignment is used to unlock
  * `is_unlocked_for_student?(student)` - true when either the assignment is unlocked for the student or no unlock conditions are present
  * `check_unlock_status(student)` - checks to see if all unlock conditions have been completed: if so, the assignment's unlock state for the student is set to unlocked
  * `find_or_create_unlock_state(student)` - finds the assignment's unlock state for the student, creating it if it does not already exist

### Analytics

#### Instance Methods

  * `high_score` - returns the maximum number of raw points out of all of the graded and released grades
  * `low_score` - returns the minimum number of raw points out of all of the graded and released grades
  * `average` - returns average of all graded and released grade raw points
  * `earned_average` - returns average of all graded and released grade scores (not raw). Returns 0 if no graded or released grades are present
  * `median` - returns median of all graded and released grade scores
  * `completion_rate(course)` - returns rate of students that have completed the assignment. Calculated by dividing the number of graded or released grades by the total number of students in the course, rounded to two decimal places
  * `submission_rate(course)` - returns rate of student submissions for the assignment. Calculated by dividing the number of submissions by the total number of students in the course, rounded to two decimal places
  * `earned_score_count` - returns a hash with each key being a grade's number of raw points, and the value being how many times it has been a grade's number of raw points. Note that this method has been moved from the assignment model to the 'Gradeable' concern
  * `percentage_score_earned` - returns a hash with one key, "scores", that is an array of hashes with the `earned_score_count` keys and values in them as "name" and "data", respectively

### Assignment Score Levels

#### Instance Methods

  * `has_levels?` - returns true if assignment score levels are present
  * `grade_level(grade)` - returns name of the assignment score level that was used to grade the student
  * `score_levels_set` - returns assignment score levels if they are present

### Assignment Weights

#### Instance Methods

  * `weight_for_student(student, weight = nil)` - if the weight is greater than 0, then it's returned (set to the student's weight if nothing was passed in). Otherwise, returns the default weight
  * `default_weight` - returns the course's default assignment weight. This will be multiplied by assignments that are not weighted

### CSV

#### Instance Methods

Each method returns a CSV string and has an optional argument `optional` that can be passed into `CSV.generate`. Each row corresponds to a student enrolled in the assignment's course.

  * `gradebook_for_assignment` - "Score", "Raw Points", "Feedback" and "Last Updated" will be left out of a row if its student has not been given a grade. Columns:
    * "First Name", "Last Name", "Uniqname", "Score", "Raw Points", "Statement", "Feedback", "Last Updated"
  * `email_based_grade_import` - "Score" and "Feedback" will be left out of a row if its student has not been given a grade. Columns:
    * "First Name", "Last Name", "Email", "Score", "Feedback"
  * `username_based_grade_import` - same as `email_based_grade_import`, except instead of the "Email" column, it has the "Username" column

### Predictor

#### Instance Methods

  * there are three methods returning true depending on what the points predictor display is set to:
    * `fixed?` - "Fixed"
    * `slider?` - "Slider"
    * `select?` - "Select List"
  * `predicted_count` - number of grades in the assignment with predicted scores greater than 0
  * `predictor_display_type` - returns a string based on the following conditions:
    * points predictor display is set to fixed or the assignment is "pass or fail", in which case "checkbox" is returned
    * points predictor display is set to slider, in which case "slider" is returned
    * neither of the above two conditions are met, in which case "slider" is returned as default

### Rubrics

#### Instance Methods

  * `grade_with_rubric?` - returns true when rubrics are enabled for the assignment, the rubric is present, and the rubric has at least one criteria
  * `fetch_or_create_rubric` - returns the rubric, creating it if it does not already exist

#### Future Use

#### Attributes

  * `max_submissions`
  * `grading_due_at`
  * `accepts_resubmissions_until`

## Assignment Score Level Model

  * Assignment Score Levels provide an easy way for instructors to grade Assignments without using a Rubric
  * Depending on the Assignment model's `mass_grade_type`, instructors may select an Assignment Score Level to give to students from radio buttons or a dropdown list in the quick grading page
  * belongs to the Assignment model
  * much of the code was factored out into the Score Level model (*see [[Model Concerns]]*)
