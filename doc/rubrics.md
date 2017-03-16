# Rubrics

Rubrics can be used by instructors to grade students for an assignment. Rubrics are composed of [Criteria](#criteria) which describe the different measures on which a grade is based. Each criterion is composed of [Levels](#levels), which differentiate the quality of work according to that criterion, and the corresponding score level.

The total grade score is calculated by summing the level score for each criterion. Currently there is no way to override the level points or the corresponding summed score for an Assignment with a Rubric (a requested feature). However, this can be unofficially accomplished using the 'quick grade' form, or by grade uploads.

Rubric Example:

|  Criterion      | Level 1  | Level 2  | Level 3   |
| --------------- | -------- | -------- | --------- |
| "Well Written"  | 0 points | 5 points | 10 points |
| "Creativity"    | 0 points | 5 points | 10 points |
| "Scholarliness" | 0 points | 5 points | 10 points |

### Included Concerns

  * [[Copyable | model concerns]]

### Associations

#### belongs_to

  * [[Assignment | assignments]]

#### has_many

  * [Criteria](#criteria)

### Instance Methods

  * `designed?` - returns true when the rubric has at least one criterion
  * `max_level_count` - returns the highest number of levels found in a single criterion. Used to set the colspan in views that display a rubric using tables

## Criteria

  * Each Criterion represents a different aspect of a Rubric
  * Each Level of a Criterion has a point value and badges that students may earn towards their grade

### Included Concerns

  * [[Copyable | model concerns]]

### Associations

#### belongs_to

  * [[Rubric | rubrics]] - rubric's timestamp is updated whenever the criterion is saved
  * [Full Credit Level](#full-credit-levels) - designated full credit level for the criterion. When the criterion is saved, the full credit level's timestamp is updated

#### has_many

  * [Levels](#levels) - when a criterion is destroyed, all of its levels will also be destroyed
  * [[CriterionGrades | criterion-grades]]

### Attributes

  * `description` - description of the Criterion. Optional for the instructor
  * `max_points` - maximum points that students may receive for the Criterion. Levels may still have a higher `points` value than this. Must be present
  * `meets_expectations_level_id` - id of the current level that meets expectations for the criteria
  * `meets_expectations_points` - number of points that meets expectations for the criteria
  * `name` - name of the Criterion. Must always be present and contain no more than 30 characters
  * `order` - currently unused. Criteria are instead ordered by index in the "rubrics/design" view. Must be present
  * `add_default_levels` - boolean switch controlling whether the default levels (the Full Credit Level and the No Credit Level) will be set upon creation of a Criterion. If true, the Full Credit Level's `points` will always be set to the Criterion's `max_points` upon saving (*see below for more information*). Not stored in the database

### Instance Methods

  * `update_meets_expectations!(level, state)` - `state` is the value that the `meets_expectations` attribute of the passed in level, `level`, needs to be updated to. Returns false before anything can be done if the passed in level does not belong to the criterion. When the passed in `state` is true and the passed in `level` does not meet expectations:
    * `meets_expectations` of the passed in level is set to true
    * `meets_expectations` of all other levels is set to false
    * `meets_expectations_level_id` is set to the passed in level
    * `meets_expectations_points` is set to the passed in level's `points` attribute
  When the passed in `state` is false and the passed in `level` *does* meets expectations:
    * `meets_expectations` of the passed in level is set to false
    * `meets_expectations_level_id` is set to nil
    * `meets_expectations_points` is set to zero
  * `comments_for(student_id)` - returns the comments belonging to the criterion's criterion grade for the passed in student. The comments are returned in the form of a string

#### Private

  * `add_default_levels?` - returns true when the `add_default_levels` attribute is true. Used in the 'if' option for callback methods
  * `create_full_credit_level` - creates a full credit level, passing in the following values:
    * `name` - "Full Credit"
    * `points` - criterion's `max_points`
    * `full_credit` - true
    * `durable` - true
    * `sort_order` - 0
  * `create_no_credit_level` - creates a no credit level, passing in the following values:
    * `name` - "No Credit"
    * `points` - 0
    * `no_credit` - true
    * `durable` - true
    * `sort_order` - 1000

#### Unused

  * `find_and_set_full_credit_level` - sets the `full_credit_level` attribute to the first level found where `full_credit` is true. If `full_credit_level` is still nil, one is created with default values using `create_full_credit_level`. Regardless, the `full_credit_level_id` attribute is then updated to the full credit level's id. Private

### Callback Methods

#### after_initialize

  * `set_defaults` - Sets `add_default_levels` to true

#### after_create

  * `generate_default_levels` - generates the default no credit and full credit levels if `add_default_levels` is true

#### Unused

  * `update_full_credit`

### Scopes

  * `ordered` - orders the criteria using the `order` attribute. Unused

## Levels

  * Levels represent how well a student does in a criterion.

For example: if the assignment was to eat apples, speed could be a Criterion, with each Level in the Criterion being a threshold for how fast the apple was eaten, eg., 45 seconds, 30 seconds (with seconds represented as points). Another Level could represent the weight of the apple, eg., 1 pound, 2 pounds. Let's say a student was given a Level named "Super Fast" for the speed Criterion, with the point value being 45,000. If they were then given a Level worth 50,000 points, called "Humongous", for the weight criterion, their score for the grade would be 95,000.

|  Criterion | Level 1                               | Level 2                                       |
| ---------- | ------------------------------------- | --------------------------------------------- |
| Speed      | **Fast** (45 seconds) - 30,000 points | **Super Fast** (30 seconds) - 45,000 points   |
| Size       | **Big** (1.5 lbs) 40,000              | **Humongous** (2 pounds) 50,000 points        |

### Included Concerns

  * [[Copyable | model concerns]]

### Associations

#### belongs_to

  * [Criteria](#criteria)

#### has_many

  * [[Level Badges | badges]]
  * [[Badges]] - through Level Badges
  * [[Criterion Grades | criterion-grades]]

### Attributes

  * `name` - name of the Level. No Credit Levels are given the name "No Credit" when created, while Full Credit Levels are given the name "Full Credit". Must always be present and contain no more than 30 characters
  * `description` - description of the Level. Optional for instructors
  * `points` - score that students will receive for the Criterion. Must always be present and at least 0
  *Removed* - `durable` - boolean switch controlling whether the Level can be deleted by an instructor. If false, an "X" will appear in the rubric design view for the Level, which deletes it when clicked. Only ever true by default for Full Credit and No Credit Levels
  * `full_credit` - boolean representing whether the Level is the Full Credit Level for its Criterion
  * `no_credit` - boolean representing whether the Level is the No Credit Level for its Criterion
  * `meets_expectations`
  * `sort_order` - order in which the Level is displayed in the Criterion.

### Instance Methods

  * `above_expectations?` - returns true when the number of points that the level gives out is greater than

### Scopes

  * `sorted` - orders by the `points` attribute, ascending

## Full Credit Levels

  * Full Credit Levels are Levels whose points represent "Full Credit" for that Criterion
  * Every Criterion has one Full Credit Level
  * Levels with point values higher than Full Credit are also possible (extra credit, exceptional performance etc.)

## No Credit Levels

  * No Credit Levels are the opposite of Full Credit Levels
  * Its point value is always the least amount a student may earn for a Criterion, and defaults to 0
  * Like Full Credit Levels, Criteria can only have one No Credit Level
