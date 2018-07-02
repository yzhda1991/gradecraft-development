# Badges

  * Is a [customizable term](customizable terms)
  * Awarded to students by instructors

### Included Concerns

*Documentation for the following concerns can be found in the [[Model Concerns]] page.*

  * Copyable
  * UnlockableCondition
  * MultipleFileAttributes

### Associations

#### belongs_to

  * [[Course | Courses]] - `updated_at` attribute will be set to the current date when one of its badges is saved

#### has_many

When a Badge is destroyed, all of the following belonging to it will be destroyed as well.

  * [[Earned Badges]]
  * [[Level Badges]]
  * Predicted Earned Badges
  * Badge Files

### Attributes

  * `name` - name of the badge. Must be present
  * `description` - description of the badge
  * `icon` - optional image for the badge. If an image was not set by the instructor, 'badge.png' is used instead
  * `visible` - boolean switch controlling whether students can see the badge. Defaults to true
  * `can_earn_multiple_times` - boolean switch controlling whether students may earn the badge multiple times. Defaults to true
  * `full_points` - number of points that the student earns for the badge. When `can_earn_multiple_times` is true, students are given the value of `full_points` for every instance of the badge that they receive. Must either be a number or blank
  * `visible_when_locked` - boolean switch representing whether the badge will be visible when it is locked
  * `student_predicted_earned_badge` - predicted earned badge for students. Only ever set in the badges controller for use with the `student_predictor_data` jbuilder view in 'badges'. Not stored in the database

### Permissions

BadgeProctor used to manage access

#### Unlocks

  * `is_unlockable?` - true if the badge has unlock conditions
  * `is_unlocked_for_student?(student)` - true when either the badge is unlocked for the student or no unlock conditions are present
  * `is_a_condition?` - true if the badge has unlock conditions
  * `unlockable` - returns the unlockable object that the badge is used to unlock
  * `check_unlock_status(student)` - checks to see if all unlock conditions have been completed: if so, the badge's unlock state for the student is set to unlocked
  * `find_or_create_unlock_state(student)` - finds the badge's unlock state for the student, creating it if it does not already exist

#### Earned Badges Metrics

  * `earned_count` - number of earned badges the badge has
  * `earned_badge_count_for_student(student)` - count of how many times the student has earned the badge
  * `earned_badge_total_points(student)` - sum of all the earned badges' points for this badge for the student
