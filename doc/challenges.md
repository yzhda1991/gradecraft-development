# Challenges

  * Is a [[customizable term | customizable terms]]
  * Challenges are the equivalent of [[Assignments]] for [[Teams]]
  * Instructors grade each Team in a Challenge
  * The sum of all Challenge Grade scores for a team can be added to each member's total course score

### Challenge Model

### Included Concerns

*Documentation for the following concerns can be found in the [[Model Concerns]] page.*

  * Copyable
  * ScoreLevelable
  * UploadsMedia
  * UploadsThumbnails
  * MultipleFileAttributes

#### Associations

##### belongs_to

  * [[Course | Courses]] - when a Challenge is saved, the `updated_at` attributes of all the Courses it belongs to will be set to the current date

##### has_many

When a Challenge is destroyed, all of its Challenge Grades, Predicted Earned Challenges and Challenge Files will be as well. All models except for Submission and Predicted Earned Challenge may have attributes nested in the challenge that they belong to.

  * [[Submissions]]
  * Challenge Grades
  * Predicted Earned Challenges
  * Challenge Score Levels
  * Challenge Files

#### Attributes

  * `name` - name of the challenge. Must be present
  * `description` - description of the challenge
  * `visible` - boolean switch representing whether students may see the challenge on their teams page. Defaults to true
  * `full_points` - maximum amount of points teams may earn for their challenge grade
  * `due_at` - date that the challenge is due by. Only displayed, never enforced

##### Future Use

  * `open_at` - date when the challenge opens up to teams
  * `accepts_submissions` - displayed in the challenges index page, but never implemented

##### Unused

  * `levels`

#### Validation Methods

  * `positive_points` - invalid when the point total is present and less than 1
  * `open_before_close` - invalid when the open and due dates are present, and the open date is after the due date

#### Instance Methods

  * `challenge_grades_by_team_id` - returns a hash of challenge grades grouped by team ids, with each key being a team id, and each value being the team's challenge grade for the challenge. Only used in the next method
  * `challenge_grade_for_team(team)` - returns the specified team's challenge grade for the challenge
  * `future?` - returns true if the due date is present and has not passed yet. Used in the student syllabus to only display the due date when true
  * `graded?` - returns true if the challenge has been graded at least once
  * `find_or_create_predicted_earned_challenge(student)` - finds or creates a predicted earned challenge using the challenge and passed in student
  * `content` - returns an html string containing a link to the challenge's show view, the description, and a list containing links to all challenge files

##### Future Use

  * `challenge_submissions_by_team_id` - broken, as no challenge submission model exists. Only used in the next method
  * `challenge_submission_for_team(team)` - returns the challenge submission associated with the specified team using the above method

## Challenge Grades

  * Challenge Grades are Grades given out to Teams for Challenges

### Challenge Grade Model

#### Associations

##### belongs_to

  * [[Course | Courses]]
  * Challenge
  * [[Team | teams]] - saved automatically whenever its Challenge Grade is saved
  * [[Submission | submissions]] - optional
  * Task - optional

#### Attributes

  * `name` - name of the challenge
  * `score` - number of points that the team receives
  * `text_feedback` - instructor's feedback for the team regarding the challenge
  * `complete` - same as grade
  * `instructor_modified` - same as grade
  * `student_visible` - same as grade

##### Future Use

  * `final_points`
  * `feedback`

#### Instance Methods

  * `score` - returns the score, or 0 if the score is not present
  * `cache_team_scores` - updates the challenge grade score and average score for the challenge grade's team. Used in ChallengeGradeUpdatePerformer

## Challenge Score Level Model

  * Challenge Score Levels provide an easy way for instructors to grade challenges as opposed to entering scores manually
  * belongs to the Challenge model
  * much of the code was factored out into the Score Level model (*see [[Model Concerns]]*)

## Challenge Grade Routes

            release_challenge_challenge_grades POST /challenges/:challenge /challenge_grades/release     challenges/challenge_grades#release
          mass_edit_challenge_challenge_grades GET  /challenges/:challenge_id/challenge_grades/mass_edit   challenges/challenge_grades#mass_edit
        mass_update_challenge_challenge_grades PUT  /challenges/:challenge_id/challenge_grades/mass_update challenges/challenge_grades#mass_update
                    challenge_challenge_grades POST /challenges/:challenge_id/challenge_grades             challenges/challenge_grades#create
                 new_challenge_challenge_grade GET  /challenges/:challenge_id/challenge_grades/new         challenges/challenge_grades#new
                          edit_challenge_grade GET    /challenge_grades/:id/edit                             challenge_grades#edit
                               challenge_grade GET    /challenge_grades/:id                                  challenge_grades#show
                                               PATCH  /challenge_grades/:id                                  challenge_grades#update
                                               PUT    /challenge_grades/:id                                  challenge_grades#update
                                               DELETE /challenge_grades/:id                                  challenge_grades#destroy
