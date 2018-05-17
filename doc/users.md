# Users

## User Model

### Associations

#### belongs_to

  * [[Default Course | course]] - actual class name is Course. `updated_at` attribute is set to the current date whenever one of its Users is saved

#### has_many

When a User is destroyed, all of its Course Memberships, Student Academic Histories, Unlock States, Submissions, Grades, Earned Badges, Group Memberships, Team Memberships and Team Leaderships will be as well.

  * Course Memberships
  * [[Courses | course]] - through Course Memberships
  * [[Users]] - through Courses
  * [[Assignments]] - through [[Grades]]
  * Created Submissions - unused, as model does not seem to exist. Polymorphic
  * [[Graded Grades | grades]] - foreign key is `graded_by_id`. Actual class name is Grade
  * [[Badges]] - through Earned Badges
  * Groups - through Group Memberships
  * Assignment Groups - through Groups
  * Team Leaderships - foreign key is `leader_id`
  * [[Teams]] - through Team Leaderships

##### `student_id` Foreign Key Associations

  * Student Academic Histories
  * Unlock States
  * Assignment Weights
  * [[Submissions]]
  * [[Grades]]
  * [[Earned Badges | badges]]
  * Group Memberships
  * Team Memberships

### Attributes

  * `username` - must always be present and less than fifty characters
  * `email` - user's email address. Must always be present and follow the traditional email format. Must be unique, regardless of casing
  * `password` - requires confirmation
  * `password_confirmation` - confirmation for password. Not stored in database
  * `activation_state` - value can either be nil or "active". Set by Sorcery
  * `avatar_file_name` - file name of the avatar picture
  * `first_name` - must be present
  * `last_name` - must be present. Used to order all student display pages except for the leaderboard and top/bottom 10
  * `display_name` - used as the public name for the user when present. Currently being phased out in favor of moving this to the course membership to allow for multiple settings per user.
  * `last_activity_at` - last datetime that the user logged in. Set by sorcery
  * `team_role` - role that student will have in a team. Currently being phased out in favor of moving this to the course membership to allow for multiple settings per user.
  * `internal` - boolean representing whether user has an internal University of Michigan email address

#### Unused

Note that, excluding the first four, none of the following attributes are stored in the database.

  * `last_login_at` - set by sorcery, never used
  * `last_logout_at` - set by sorcery, never used

### Class Methods

In addition to the methods below, there is one for each role a student may have in a course: `students`, `professors`, `gsis` and `admins` — all with the course as an argument. Each of these methods simply calls `with_role_in_courses` and returns the result, passing in the method's corresponding role and the course

  * `with_role_in_courses(role, course)` - returns all users in the courses with the role passed in. If the role passed in is "staff", all users who are either professors or gsis are returned. Otherwise, all students with the role passed in are returned
  * `students_being_graded(course, team)` - returns the ids of all students in the passed in course whose grades are included in course analysis. Passed in team is set to nil by default
  * `students_by_team(course, team)` - returns all members of the team in the course
  * `unscoped_students_being_graded_for_course(course, team=nil)` - returns a query that selects the id, first name, last name, email, last time updated, and course membership score for all students in the passed in course who are being graded. User query is joined with the course and team memberships
  * `find_or_create_by_lti_auth_hash(auth_hash)` - finds or creates — and returns — a user with an email equal to the one in the hash. In the process, the first name, last name and username of the user are set to their corresponding values in the hash
  * `find_by_kerberos_auth_hash(auth_hash)` - returns the user with the same kerberos uid as the one in the hash
  * `find_by_insensitive_email(email)` - returns the user with the passed in email address, ignoring case
  * `find_by_insensitive_username(username)` - returns the user with the passed in username, ignoring case
  * `email_exists?(email)` - returns true when a user is found with the passed in email address
  * `auditing_students_in_course(course_id)` - returns all students joined with course memberships whose grades are excluded from course analysis in the passed in course
  * `graded_students_in_course(course_id)` - returns all students joined with course memberships whose grades are included in course analysis in the passed in course
  * `auditing_students_in_course_include_and_join_team(course_id)` - returns `auditing_students_in_course`, joined with the student's team membership

### Instance Methods

In addition to the methods described below, there are methods of the form `is_<role>?(course)` that return true when the user has the method's corresponding role. For example, to find out if a user is a student in the first course, you could call `is_student(Course.find(1))`.

  * `internal?` - returns true when the user has a University of Michigan email address
  * `activated?` - returns true if the user has been activated (with Sorcery)
  * `name` - returns one of three things:
    * the first name is present, but the last name is not - first name is returned
    * the last name is present, but the first name is not - last name is returned
    * first and last names are not present - "User <id>" is returned
  * `public_name` - display name is returned when present; otherwise, `name` method is returned
  * `student_directory_name` - returns the user's name in the form "smith, john"
  * `student_directory_name_with_username` - returns the student's directory name and username in the form of "{directory name} - {username}"
  * `full_name` - returns the user's full name
  * `same_name_as?(another_user)` - returns true when the user shares a full name with the passed in user
  * `role(course)` - returns the role of the student
  * `is_staff?(course)` - returns true when the student is either a professor, gsi or admin in the passed in course
  * `team_for_course(course)` - sets the instance variable `team` to the student's team in the passed in course, which is also returned. Duplicate methods appear at lines 253 and 416
  * `team_leaders(course)` - returns all of the team leaders in the user's team for the course
  * `team_leaderships_for_course(course)` - returns all of the teams that the user leads for the course
  * `character_profile(course)` - returns the character profile for the passed in course
  * `archived_courses` - returns all of the user's finished courses
  * `cached_score_for_course(course)` - sets the instance variable `cached_score` to and returns the student's score in the passed in course. If the score is not present, zero is returned
  * `grade_for_course(course)` - returns the grade scheme element for the student's score in the course
  * `grade_level_for_course(course)` - returns name/level of the grade scheme element for the student's score in the course
  * `grade_letter_for_course(course)` - returns letter of the grade scheme element for the student's score in the course
  * `next_element_level(course)` - needs to be fixed
  * `points_to_next_level(course)` - returns the amount of points that the student is away from the next grade scheme element
  * `grade_visible_for_assignment?(assignment)` - returns true when the student's grade for the assignment is either graded and does not need to be released, or is released
  * `grade_for_assignment(assignment)` - returns the student's grade for the assignment if it exists. If not, creates and returns a new one
  * `grade_for_assignment_id(assignment_id)` - returns the student's grade for the assignment using the passed in assignment id
  * `cache_course_score(course_id)` - recalculates the student's score for the course. Powers the worker
  * `improved_cache_course_score(course_id)` - recalculates and returns the student's score for the course. Powers the worker
  * `fetch_course_membership(course_id)` - returns the user's course membership using the course id
  * `submission_for_assignment(assignment)` - returns the student's submission for the assignment
  * `earned_badge_score_for_course(course)` - returns the amount of points the student has earned through badges in the course
  * `earned_badges_for_course(course)` - returns the student's earned badges for the course
  * `awarded_badges_for_badge(badge)` - returns all of the student's earned badges for the passed in badge. Used in the unlock condition model
  * `awarded_badges_for_badge_count(badge)` - returns the number of badges the student has earned of the type passed in. Used in the unlock condition model
  * `unique_student_earned_badges(course)` - returns all badges combined with their earned badges in the course for the student
  * `student_visible_earned_badges(course)` - returns all of the student's badges that either have been released and are not associated with a grade, or have a grade that is visible
  * `earnable_course_badges_for_grade(grade)` - returns badges that are in the same course as the grade, and in which one of the following conditions are met:
    * student has not yet earned the badge in the grade's course
    * student has earned the badge, but it can be earned multiple times
    * student has already earned the badge, and it cannot be earned multiple times, but it was earned for the passed in grade
  * `earnable_course_badges_sql_conditions(grade)` - returns all badges in which one of the following is true:
    * student has yet to earn the badge in the course
    * student has in fact earned the badge, but it can be earned multiple times
    * student has already earned the badge and multiples are not allowed, but the badge is for the passed in grade
  * `student_visible_unearned_badges(course)` - returns all badges that exist in the course and are visible, and where one of the following conditions are met:
    * student has not earned the badge, which is visible
    * student has earned the badge, but it is not student visible

#### Future Use

  * `auditing_course?(course)` - returns true when the student's grades are set to be excluded from course analysis. Tested

#### Testing

  * `earn_badge(badge)` - creates an earned badge for the student in the badge's course. A type error is raised if the passed in badge's class is not Badge
  * `earn_badge_for_grade(badge, grade)` - creates an earned badge for the student's grade in the badge's course. A type error is raised if the passed in badge's class is not Badge
  * `earn_badges_for_grade(badges, grade)` - creates and returns earned badges for the student's grade from all of the passed in badges. Uses the nonexistent variable "badge"
  * `earn_badges(badges)` - creates earned badges for the student from all of the passed in badges. A type error is raised if the passed in badges argument is not an array

#### Unused

  * `student_invisible_badges(course)` - returns badges that have been earned by the student, are not visible, and whose earned badge for the student has not yet been marked student visible
  * `weight_for_assignment(assignment)` - returns the weight of the passed in assignment
