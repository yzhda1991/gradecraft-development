# Grade Scheme Elements

  * Grade Schemes use the amount of points students have earned in a course to show them traditional letter [[grades]]
  * Grade Scheme rows are called elements
  * Students can see their predicted grade scheme element in the grade predictor

## Included Concerns

  * [[Copyable | model concerns]]

## Associations

### belongs_to

  * [[Course | Courses]]

## Attributes

  * `letter` - letter representing the student's grade. As it is a string, it is not restricted to just one character
  * `low_points` - the lowest amount of points a student may have for the course to receive the grade scheme element
  * `high_points` - the highest amount of points a student may have for the course to receive the grade scheme element
  * `level` - essentially the name of the grade scheme element, eg., "Elephant"

### Future Use

  * `description`

## Instance Methods

  * `points_to_next_level(student, course)` - how many points away the student is from the next level for the course. Used in the 'students/course_progress' view
  * `progress_percent(student, course)` - percentage student is through the level. Used in the 'students/course_progress' view
  * `range` - amount of points that the grade scheme element covers (high range minus low range)
