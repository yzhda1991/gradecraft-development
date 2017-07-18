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

*Note that when discussing grades in an assignment, we are always referring to grades that are student visible*

  * `no_grade(attrs)` - used for rejecting the nested attributes of a grade. When the model's `pass_fail` attribute is true, the method returns true if the grade's pass fail status is empty. When `pass_fail` is false, the method returns true if the grade's `raw_points` attribute has not been set yet
  * `grade_for_student(student)` - returns the passed in student's grade for the assignment. Returns nil if the grade has neither been graded nor released, or if the grade does not yet exist
  * `is_predicted_by_student?(student)` - returns true if the passed in student has a predicted earned grade for the assignment
