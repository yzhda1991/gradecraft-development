## CriterionGrades

When grading with a rubric, a CriterionGrade is created for each Criterion and associated with a Level, from which it receives its points.

Assignment grades created using a rubric are calculated from the sum of the CriterionGrades.

### CriterionGrade Model

#### Associations

##### belongs_to

  * [Criteria](#Criteria)
  * [Level](*Level)
  * [[Student | users]]
  * [[Assignment | assignments]]

#### Attributes

  * `points` - set to the `points` attribute of the level
  * `comments` - set to the `comments` attribute of the criterion

#### Class Methods

  * `find_or_create(assignment_id, criterion_id, student_id)` - finds the CriterionGrade which belongs to the passed in assignment, criterion and student. Used in /app/services/ when creating and updating rubric-created grades
