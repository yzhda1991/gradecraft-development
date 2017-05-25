# Concerns

*This page is intended to give descriptions of the Active Support concerns created for use with the models.*

## Copyable

* provides methods to make implementing object copying easier
* created for models like [[Assignment | assignments]] and [[Course | Courses]] that need to be duplicated by instructors

### Instance Methods

  * `copy(attributes={})` - creates a duplicate of the object, passes the optional hash of attribute values to `copy_attributes`, and returns the duplicate
  * `copy_attributes(attributes)` - takes a hash of attribute names and values, copying the values from the hash to the instance

### Models

The Copyable concern is currently used in the following models:

  * [[Assignment Type | assignment types]]
  * [[Assignment | assignments]]
  * [[Badge | badges]]
  * [[Challenge | challenges]]
  * [[Course | Courses]]
  * [[Criterion | rubrics]]
  * [[Grade Scheme Element | grade scheme elements]]
  * [[Level | rubrics]]
  * [[Rubric | rubrics]]

## Gradable

See [[Gradable]].

## GradeStatus

  * adds behavior related to grade statuses for models that represent some form of a grade
  * used (`include`d) in `Grade` and `ChallengeGrade` models
  * for an in-depth explanation of how grade statuses work, see [[Grade Statuses | grade status]]

Note that in this section the term "grade" refers to both Grades and Challenge Grades.

### Attributes

  * `status` - status of the grade. Set to either "In Progress," "Graded," or "Released"

### Scopes

  * `graded` - grades that have a `status` of "Graded"
  * `graded_or_released` - grades that have a `status` of "Graded" or "Released"
  * `in_progress` - grades that have a `status` of "In Progress"
  * `not_released` - grades that have a status of "Graded," joined with `releasable_relationship` (ie., the assignment or challenge). No grades will be returned when `release_necessary` from `releasable_relationship` is false
  * `released` - grades, joined with the assignment/challenge, that meet one of two requirements:
    * status that is set to "Released"
    * status that is set to "Graded", with the assignment/challenge's `release_necessary` being false
  * `student_visible` - appears to produce the exact same SQL query as `released`, though the where clause of `student_visible` comes from the private instance method `student_visible_sql`

### Instance Methods

  * `is_graded?` - returns true if the status is set to "Graded"
  * `in_progress?` - returns true if the status is set to "In Progress"
  * `is_released?` - returns true if the status is set to "Released"
  * `graded_or_released?` - returns true if the status is set to either "Graded" or "Released"

## Historical

  * keeps track of changes to models using [PaperTrail](https://github.com/airblade/paper_trail)
  * for a description of the methods that PaperTrail provides, see the [API Summary](https://github.com/airblade/paper_trail).

### Instance Methods

  * `has_history?` - returns true if the model has at least one version
  * `history` - returns an array of elements combining the following attributes with each version's changeset:
    * `object` - model's class name
    * `event` - version's event (value can be 'create', 'update' or 'destroy')
    * `actor_id` - id, as a string, of the user who made the change
    * `recorded_at` - time that the event occurred
  * `historical_merge(historical_model)` - returns a merged history of the model and the passed in historical model

### Models

  * [[Grade | grades]]
  * [[Submission | submissions]]

## MultipleFileAttributes

  * provides a class method that creates setter methods for nested file attributes in models, making adding multiple files to a model easier

### Class Methods

  * `multiple_files(files_attributes)` - creates a setter method in the model for nested attributes, with the name being the model's file model, `files_attributes`, followed by an underscore and 'attributes' (eg., 'assignment_files_attributes'). In the setter method, files are retrieved from the hash argument, `attributes`, and added as files to the model using nested attributes

### Models

  * [[Assignment | assignments]]
  * [[Badge | badges]]
  * [[Challenge | challenges]]
  * [[Grade | grades]]
  * [[Submission | submissions]]

## Sanitizable

  * adds class methods that remove any malicious code from passed in attributes

### Class Methods

  * `clean_html(attributes=[])` - passes in each attribute in the array to the method below
  * `clean_html_before_save(attribute)` - sets the attribute with the passed in name to be cleaned of any malicious code before every save in the model

### Models

  * [[Assignment | assignments]]
  * [[Grade | grades]]
  * Group
  * [[Submission | submissions]]

## ScoreLevel

  * implements commonalities between the assignment and challenge score level models for grades
  * includes Copyable concern

### Attributes

  * `name` - name of the level. Must be present
  * `points` - points earned without being weighted that students will receive for their grade. Must be present

### Instance Methods

  * `formatted_name` - returns a string containing the name (`name`) and amount of points to be awarded (`points`). Used for selecting from a list of score levels

### Scopes

  * `order_by_value` - ordered by value, descending

### Models

  * [[Assignment Score Level | assignments]]
  * [[Challenge Score Level | challenges]]

## ScoreLevelable

  * used in models that have many score levels
  * the ScoreLevel concern is for the score level model (eg., AssignmentScoreLevel), while the ScoreLevelable concern is for whatever model it belongs to (eg., Assignment)

### Class Methods

  * `score_levels(levels, *options)` -
    * declares a has_many association, passing in both arguments
    * sets the model to accept nested attributes for the passed in model `levels`, allowing the levels to be destroyed with the `_destroy` key and rejecting any with a blank `points` or `name`

### Models

  * [[Assignment | assignments]]
  * [[Challenge | challenges]]

## UnlockableCondition

*Page dedicated to describing how unlocks work will be added in the future.*

## UploadsMedia

  * implements uploading in the models for "media" images
  * must have either a 'jpg', 'jpeg', 'gif', or 'png' extension

### Attributes

  * `media` - the file itself. Maximum size of 2 megabytes
  * `media_credit`
  * `media_caption`
  * `remove_media`

### Partial

  * `media_image_form_item` partial is used for uploading media images, along with credits and captions
  * image width set to 40 when uploaded

### Models

  * [[Assignment | assignments]]
  * [[Challenge | challenges]]
  * [[Course | Courses]]
  * Event

## UploadsThumbnails

  * implements uploading in the models for "thumbnail" images
  * must have either a 'jpg', 'jpeg', 'gif', or 'png' extension

### Attributes

  * `thumbnail` - the file itself. Maximum size of 2 megabytes
  * `remove_thumbnail`

### Partial

  * `thumbnail_image_form_item` partial is used for uploading thumbnail images
  * image set to 25 × 25 when uploaded

### Models

  * [[Assignment | assignments]]
  * [[Challenge | challenges]]
  * Event
