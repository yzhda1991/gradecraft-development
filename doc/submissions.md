# Submissions

  * Submissions allow students to submit links, text content and files for assignments
  * They are optional, as professors may grade a student regardless of whether they have submitted their assignment
  * Submissions may be edited by a student if the assignment is still open, and if the grade has not been released or resubmissions are allowed
  * Submissions may also be edited by a professor, regardless of resubmission or open settings
  * Submission history is tracked via [PaperTrail](https://github.com/airblade/paper_trail)
  * Submissions have an implied _Draft_ state, as described by the `draft?` method on the Submission. For more information regarding draft Submissions, see [[Submission Drafts]]

## Included Concerns

*Documentation for the following concerns can be found in the [[Model Concerns]] page.*

  * Historical
  * MultipleFileAttributes
  * Sanitizable

## Associations

### belongs_to

Note that for all of these models, the `updated_at` attribute will be set to the current time when a submission it has is saved.

  * Task
  * [[Assignment | assignments]]
  * [[Student | users]] - actual model name is User
  * [[Creator | users]] - actual model name is User
  * Group
  * [[Course | Courses]]

### has_one

  * [[Grade | grades]]
  * [[Assignment Weight | assignments]] - through Assignment

### has_many

When a [[Submission | submissions]] is destroyed, the following models that belong to the Submission will be as well

  * [[Rubric Grades | rubrics]]
  * Submission Files - when a Submission is saved, all of its Submission Files will be as well

## Attributes

  * `link` - url link that the student may use for their submission. Optional
  * `text_comment` - comment/content/statement in text that the student may use for their submission.
  * `text_comment_draft` - identical to `text_comment` but intended for storing autosaved user input

### Unused

## Callback Methods

### before_save

  * `clean_html` - removes html from the text comment
  * `submit_something` - returns true if the submission contains a link, comment or files

### after_save

  * `check_unlockables` - unlocks all unlockable objects where possible that use the submission's assignment as an unlock condition

### before_validation

  * `cache_associations` - if the task is present, the assignment id, assignment type and course id are set to the task's assignment attributes of the same name. Otherwise, the three attributes are set to the assignment's id, assignment type and course id, respectively

## Instance Methods

  * `updatable_by?(user)` - returns true when the passed in user, or their group, submitted the assignment. Used by Canable
  * `destroyable_by(user)` - returns true when the passed in user, or their group, submitted the assignment, or if the assignment is not for groups and the user is staff for the course. Used by Canable
  * `ungraded?` - returns true when the grade or its status is not present. Used in the "Grading Status"
  * `viewable_by?(user)` - identical to `updatable_by?(user)`. Used by Canable
  * `name` - returns the name of the student who submitted the work
  * `late?` - returns true if the submission was created after the assignment's due date
  * `has_multiple_components?` - returns true when the student submitted more than one file, or all three submission fields are present (files, link and comment). Used for exporting submissions
  * `will_be_resubmission?` - returns true if the Submission has been graded. Used to report to the user that a change will be a resubmission
  * `resubmissions` - returns a list of submission changes and the grade changes
  * `resubmitted?` - returns true if there has been Resubmission recorded
  * `draft?` - returns true if `submitted_at = nil`
