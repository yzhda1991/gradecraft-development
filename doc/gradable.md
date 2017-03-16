# Gradable

  * currently only `include`d in the [[Assignment | assignments]] model
  * adds grade-related associations and methods
  * accepts nested attributes for grades, as long as `no_grade` returns true (see below)

## Associations

### has_many

When an instance of a model that `include`s Gradable is destroyed, its grades and predicted earned grades will be destroyed as well

  * [[Grades]]
  * Predicted Earned Grades

## Instance Methods

*Note that when discussing grades in an assignment, we are always referring to grades that have either been graded or released*

  * `no_grade(attrs)` - used for rejecting the nested attributes of a grade. When the model's `pass_fail` attribute is true, the method returns true if the grade's pass fail status is empty. When `pass_fail` is false, the method returns true if the grade's `raw_points` attribute has not been set yet
  * `graded_or_released_scores` - returns an array consisting of the `raw_points` values from every grade in the assignment
  * `grade_count` - number of grades in the assignment
  * `grade_for_student(student)` - returns the passed in student's grade for the assignment. Returns nil if the grade has neither been graded nor released, or if the grade does not yet exist
  * `average` - returns the average number of raw points out of all grades belonging to the assignment
  * `earned_average` - returns the average score of all grades in the assignment that have scores greater than zero
  * `earned_score_count` - returns a hash with a key being a number of raw points and that key's value being the number of grades in the assignment that have that number of raw points
  * `high_score` - returns the highest number of raw points out of all grades in the assignment
  * `low_score` - returns the lowest number of raw points out of all grades in the assignment
  * `is_predicted_by_student?(student)` - returns true if the passed in student has a predicted earned grade for the assignment
  * `median` - returns the median score out of all of the grades in the assignment
  * `predicted_count` - returns the number of predicted earned grades in the course that have a `predicted_points` attribute greater than zero
