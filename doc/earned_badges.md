## Earned Badges

When students earn a  `Badge` in GradeCraft, this information is stored in an `EarnedBadge`. Each earned badge represents one time that the student has earned the badge.

### Awarding Badges

There are currently 3 ways one can earn a badge:

  * A badge can be awarded directly to a student
  * A badge can be awarded to a student for a grade, from the grading page.
  * A badge can be awarded to a student for achieving a level in a rubric criterion

#### Direct Award

The form for directly awarding a badge is available from the badge index and show pages. This uses standard restful routing, and utilizes the `CreatesEarnedBadge` service. The `grade_id` and `level_id` fields will be left blank. `awarded_by_id` is set in the `earned_badge_params`

If a badge is `student_awardable?` this same path is available for students to award badges to other students, from the badge show page.


#### Awarded for a Grade

On the bottom of the Grading form (both standard and rubric), an Angular directive makes AJAX calls to  POST params to `/api/earned_badges`, which utilizes the `CreatesEarnedBadge` service. The `grade_id` reflects the current grade, `level_id` is left blank. `awarded_by_id` is set in the `earned_badge_params`

A successful response results in the badge count updating on the grading page.

#### Awarded for a Level

A [[LevelBadge | level badges ]] holds an associated badge and level. When a grade is submitted through the rubric grading process, the `CreatesGradeUsingRubric` service will call the `BuildsEarnedLevelBadges` service action.  `grade_id`, `level_id` and `awarded_by_id` are set in the action.

An `EarnedBadge` for the `Student`, `Level` and `Badge` is either created, or updated if one exists.

Any badge can only be awarded once per level. More than one kind of badge can be awarded per level. Any badge can be awarded on different levels for the same criterion or for the same grade. Badges set to be awarded are displayed in the rubric grading form levels, but award management is maintained solely on the back end through the service.

### Earned Badge Model

  * If a Badge's `can_earn_multiple_times` attribute is true, multiple Earned Badges may exist that belong to the same Badge and Student
  * Delegates `name`, `description` and `icon` to the Badge model

#### Associations

##### belongs_to

  * [[Course | Courses]]
  * Badge
  * [[Student | users]] - actual class is User. `updated_at` attribute set to current date when one of its earned badges is saved
  * [[Grade | grades]] - optional

##### has_many

  * Badge Files - through Badge

#### Attributes

  * `student_visible` - reflects the grade model's `student_visible?` value, or true if no associated grade
  * `feedback` - feedback for the student

#### Methods

  * `points` - reflects the badge model's `full_points` attribute

#### Callback Methods

##### before_validation

  * `add_associations` - sets `course_id` to the badge's `course_id`

##### before_save

  * `update_visibility` - updates the `student_visible` field

##### after_save

  * `check_unlockables` - unlocks all unlockable objects that use the earned badge's badge as an unlock condition and can be unlocked
