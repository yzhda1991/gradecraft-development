## Grade status

TODO: document changes before merge!

* Student created grades (i.e. when predicting a grade) have a nil status
* Professor/GSI created grades status are "In Progress", "Graded", or "Released"
  * "In Progress" -- GSI is in the middle of grading, grade is not visible to student
  * "Graded" -- instructor has graded the item, item becomes available for release by instructor
  * "Released" -- instructor has released this grade to the student
* `instructor_modified?` is a separate field that keeps track of a grade that once had a status, even if it has been reset to nil (*see TODO below*)

## Releasing grades

  * Instructor has the ability to select any or all grades with a status of "Graded" for an assignment, and then change the status for all selected grades
  * currently instructor can choose any graded status "In Progress", "Graded", "Released", or "" (*see TODO below*)

## Student Visible Grades

### Students can never see a grade when:

* status is nil, or "In Progress"

### Student can see a grade when:

  * On the assignment level: "release_necessary" is false, and grade status is "Graded" or "Released"
  * On the assignment level, "release_necessary" is true, and the grade status is "Released"

| Status         | release required | no release required  |
| -------------- | ---------------: | -------------------: |
|  "In Progress" |        NO        |          NO          |
|  "Graded"      |        NO        |          YES         |
|  "Released"    |        YES       |          YES         |

### Faculty can see a grade when:

Faculty can always see grades when they exist (but they can't see [[student grade predictions | predictor]])

### Challenge grades

Do not currently have an "In Progress" status, but otherwise work exactly the same as Assignment Grades

### TODO:
  * remove blank status from selections that are available to instructors updating a grade status
  * Grade method `is_released?` should become `is_student_visible?`
  * grade `instructor_modified?` method could be represented by `status.nil?` when we remove instructor's ability to set status to nil
