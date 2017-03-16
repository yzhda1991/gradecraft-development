# Grading

This page describes the grading process — or, more specifically, the process by which student and team points are stored.

## Grade Models

  * students can be graded individually for assignment and as part of a team for challenges
  * in the code, grades given to a team as part of a challenge are referred to as "challenge grades"; while grades given to a student individually as part of an assignment are referred to simply as "grades"

### Assignment Grades

#### Quick

Grading without using a rubric means that you can do one of two things:

  * select an assignment score level (with each one having a set number of points) if at least one exists
  * input the points that the student will receive manually (with a text box)

#### Rubric

*See [[Rubrics]] for details.*

### Challenge Grades

  * the only grading option for Challenge Grades is to input the points manually
  * for students to be given points when one of their team's challenges is graded, the current course's `add_team_score_to_student` must be true
  * grades are created and updated in the [challenge grade form view](https://github.com/UM-USElab/gradecraft-development/blob/master/app/views/challenge_grades/_form.html.haml)

## Mass Grading

  * used in both Assignment and Challenge Grades
  * allows instructors to grade all students or teams in an assignment or challenge at once
  * input type is determined by the `mass_grade_type` attribute in the assignment model for assignments, and is always a text box for challenges
  * mass grading is done in the `mass_edit` views in both the [Grades](https://github.com/UM-USElab/gradecraft-development/blob/master/app/views/challenge_grades/mass_edit.html.haml) and [Challenge Grades](https://github.com/UM-USElab/gradecraft-development/blob/master/app/views/grades/mass_edit.html.haml) folders

#### Groups

Setting grades for group assignments is currently limited to professors. `mass_edit` and `mass_update` methods account for both individual and group grading in the `Assignments::GradesController` in order to allow reuse of the existing route. `mass_update` for groups calls the `CreatesManyGroupGrades` service. 

The actions that describe the `CreatesManyGroupGrades` service are as follows:

1. `CreatesManyGroupGrades` - takes an assignment_id and raw params from controller
2. `IteratesAssignmentGroupToCreateGrades` - iterates through the groups in the params and invokes `CreatesGroupGrades` for each instance in the current context
3. `CreatesGroupGrades`
  1. `VerifiesGroup` - Validates the group_id and sets group in current context
  2. `IteratesCreatesGrade` - Similar service to IteratesCreatesGradeUsingRubric but calls `CreatesGrade` instead of `CreatesGradeUsingRubric`. Iterates through all students in the group to create grades
4. `VerifiesAssignmentStudent`
5. `BuildsGrade`
6. `AssociatesSubmissionWithGrade`
7. `MarksAsGraded`
8. `SavesGrade`
9. `RunsGradeUpdaterJob`

Steps 4-9 reuse existing actions.

### TODO:
Refactor the `BuildsGrade` service and dependent classes where it is being invoked to take a generic set of attributes and have them be updated via `grade.assign_attributes`. Strong params need to be refined for this change to work correctly.

## Updating Scores

Below is a step by step description of how student and team scores are updated in a course.

1. Instructor inputs number of points to be given to a student for an assignment.
2. One of two things happen, depending on whether the grade is for an assignment or challenge:
  * In the grade controller's update action (which also functions as a create action), the grade is passed to GradeUpdaterJob if it is visible to the student
  * In the challenge grade controller's create and update actions, a ScoreRecalculatorJob is created for every student in the team that is being graded, as long as `add_team_score_to_student` is true in the course model and the challenge grade is visible to the team
3. Eventually, the job reaches the top of the queue and `do_the_work` is called in GradeUpdatePerformer for the grade and in ScoreRecalculatorPerformer for the challenge grade.
4. `cache_course_score(course_id)` is called in the user model. The student's individual course score, which is stored in the course membership model, is set to the sum of
  * all points earned from grades and badges that are visible in the course
  * the score of the student's team, if it is enabled with `add_team_score_to_student` in the course model. Will not be added to the sum when `team_score_average` (also in the course model) is set to true
5. For only assignment grades (not challenge grades), the team's score itself is updated with `update_revised_team_score` in the team model being called. If the course model's `team_score_average` is true, the score of the student's team, which is stored in the team model, is set to the average of the members' individual scores in the course. Otherwise, the team's score is set to the sum of points earned from visible challenge grades
