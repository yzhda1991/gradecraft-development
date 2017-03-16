## Customizable Terms in Gradecraft

There are several terms in Gradecraft that can be customized on the course level. For instance, 'students' can be customized to be 'players', and then everywhere within that course's public facing pages students will be referred to as 'players' and the current student as the 'current player'.

Every customizable term is stored in a corresponding field on the Course model.

## Customizable Terms

  * assignment
  * assignment type
  * badge
  * challenge
  * group
  * pass and fail
  * student
  * team
  * team leader
  * weight

## Pluralization

Plural terms are handled as well, using the standard Rails pluralize method.

## Development

Customized terms all use the `term_for` helper, from the `CourseTerms` module: `/lib/course_terms.rb`

This module requires access to `current_course`. 

`term_for` is available in both the controllers and the views.

### Undefined Terms

The standard error message for this method is "No term defined for [some term] Please define one in lib/course_terms.rb."
