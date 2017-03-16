# Grades

## Grade Model

### Included Concerns

*Documentation for the following concerns can be found in the [[Model Concerns]] page.*

  * Historical
  * MultipleFileAttributes
  * Sanitizable

### Associations

#### belongs_to

Note that for all of these models, their `updated_at` attribute will be set to the current date when one of its Grades is saved.

  * [[Course | Courses]]
  * [[Assignment | assignments]]
  * [[Assignment Type | assignment types]]
  * [[Student | users]] - actual class name is User
  * [[Team | teams]]
  * [[Submission | submissions]]
  * Task
  * Group - polymorphic association
  * [[Graded By | users]] - actual class name is User

#### has_many

  * [[Earned Badges | badges]] - when a Grade is destroyed, all of its Earned Badges will be as well
  * [[Badges]] - through Earned Badges
  * Grade Files - when a Grade is destroyed, all of its Grade Files will be as well

### Attributes

  * `graded_by_id` - id of instructor who graded the student
  * `pass_fail_status` - boolean representing whether the student has passed or failed their assignment. The two possible values are "Pass" and "Fail". See [[pass fail assignments | pass fail]] for more information

#### Excluded Grades

  * `excluded_from_course_score` - excludes the grade from the student's course score. When a student's score is updated, the assignment type model's `score_for_student` method is eventually called, where it looks for grades with this attribute set to false among other things. Set to true in the `exclude` action, and set to false in the `include` action
  * `excluded_date` - time that the grade was excluded from the student's course score. Used in the grade show page. Set to nil in the `include` action
  * `excluded_by` - instructor that excluded the grade. Used in the grade show page. Set to nil in the `include` action

#### Grade Status

  * `instructor_modified` - boolean representing whether the grade once had a status. See [[grade status]] for more information
  * `status` - grade's status, which determines the grade's visibility to students. See [[grade status]] for more information

#### Feedback

  * `feedback` - feedback, in text form, that students may receive from instructors after their assignment is graded. Not used when the grade's assignment uses rubrics. Stripped of html before being saved
  * `feedback_read` - boolean representing whether the feedback has been read by the student. Set to true when students click "I Have Read This Feedback" in the "My Results" tab in the assignment
  * `feedback_reviewed` - boolean representing whether the student has reviewed the feedback. Unlike `feedback_read`, students must only visit the assignment's page after their grade has been released for this to be set to true
  * `feedback_read_at` - set to the current time when `feedback_read` is set to true (in the 'feedback_read!' method)
  * `adjustment_points_feedback` - reason for instructor setting number of adjustment points

#### Scores and Points

Scores and point values are saved in several states on the model. See [[Points]] for more info.

  * `full_points` - the full points for the assignment * the student's weighting
  * `raw_points` - raw points for the grade. Unlike `score`, it is never weighted
  * `adjustment_points` - points to add or subtract from the raw points (+ bonus points, - tardiness etc.)
  * `final_points` - The sum of the raw points and the adjustment
  * `score` - The final points multiplied by the student's weighting for the assignment type.

#### Future Use

  * `feedback_reviewed_at` - set to the current time when `feedback_reviewed` is set to true (in the `feedback_reviewed!` method). *See feedback description above for details*

### Class Methods

#### Unused

  * `assignment_scores` - plucks the grades' assignment ids and scores
  * `assignment_type_scores` - groups the grades by assignment type ids, plucking the assignment type id and sum of the grade scores

### Instance Methods

  * `feedback_read!` - sets `feedback_read` to true and `feedback_read_at` to the current time
  * `feedback_reviewed!` - sets `feedback_reviewed` to true and `feedback_reviewed_at` to the current time
  * `is_graded?` - returns true when the grade status is set to 'Graded'
  * `assignment_weight` - returns the student's weight for the assignment
  * `is_released?` - returns true when the grade status is set to 'Released'
  * `is_student_visible?` - returns true when either the grade is released, or it is graded and a release is not necessary
  * `status_is_graded_or_released?` - returns true when the grade status is set to 'Graded' or 'Released'. This method can also be called with `graded_or_released?`

#### Unused

  * `in_progress?` - returns true when the grade status is set to 'In Progress'
  * `has_feedback?` - returns true when the feedback is present and not an empty string
  * `altered?` - returns true when the score or feedback has been changed

### Callback Methods

#### before_validation

  * `cache_associations` - the following attributes are set to attributes of the same names in the specified models if they are not already present:
    * `student_id` - submission model
    * `task_id` - submission model
    * `assignment_id` - submission model
    * `assignment_type_id` - assignment model
    * `course_id` - assignment model

#### before_save

  * `calculate_points` - sets the `full_points`, `final_points` and `score` attributes
  * `zero_points_for_pass_fail` - if the grade's assignment is pass or fail, `raw_points`, `final_points` and `full_points` are set to 0

#### after_save

  * `check_unlockables` - unlocks all unlockable objects, where possible, that use the grade's assignment as an unlock condition

#### after_destroy

  * `save_student_and_team_scores` - caches the sum of the student's released grade and badge scores to the course membership model's `score` attribute and the team's average points to the team model's `score` attribute

## Self Logging

  * Self Logging allows students to log grades themselves
  * The self log form contains a dropdown list, which contains either the assignment score levels or simply "I have completed this work".
  * Upon clicking "I have completed this work," the student's grade score will be set to the assignment's point total
  * The Self Logging form is located in the "assignments/self_log_form" view partial, which is used in the Assignment's "show" page and in the syllabus for students
  * Three conditions must be met for the self log form to appear:
    * Student Logging must be enabled for the Assignment
    * The Assignment must be open to Submissions
    * The current user must be a student
