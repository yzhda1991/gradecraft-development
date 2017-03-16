# Teams

  * Teams are assigned to students by instructors
  * They can be given [[challenges]] that instructors grade them on

### Team Model

#### Associations

##### belongs_to

  * [[Course | Courses]] - when a team is saved, its Course's `updated_at` attribute will be set to the current time

##### has_many

  * Team Memberships
  * [[Students | users]] - through Team Memberships. When a team is saved, all of its students will be saved (and destroyed if marked for destruction)
  * Team Leaderships
  * Leaders - through Team Leaderships
  * [[Earned Badges | badges]] - through Students
  * [[Challenge Grades | challenges]]
  * [[Challenges]] - through Challenge Grades

#### Attributes

  * `name` - name of the team. Must be present and unique
  * `score` - sum of challenge grade scores for the team if the course has team challenges -- if not, average of students' released grade scores
  * `in_team_leaderboard` - boolean switch representing whether a table will be displayed to members on their teams page ranking the team's members by course score. Either this or the course's `in_team_leaderboard` attribute must be true for the table to be displayed. Defaults to false
  * `banner`

##### Unused

  * `rank`
  * `teams_leaderboard` - defaults to false

#### Callback Methods

##### before_save

  * `cache_score` - if the course has team challenges, `score` is set to the sum of challenge grade scores. Otherwise, it is set to the average of team member scores. Method will be removed in the future

#### Class Methods

  * `find_by_course_and_name(course_id, name)` - finds the course with the passed in course id and name (case insensitive)

#### Instance Methods

  * `member_count` - returns the number of students in the team
  * `badge_count` - returns number of badges that team members have earned in the course
  * `average_points` - returns average of points that members have earned from released grades in the course
  * `challenge_grade_score` - returns the sum of visible challenge grade scores
  * `update_revised_team_score` - equivalent to `cache_score`
  * `update_ranks` - updates the ranks of all teams in the course
