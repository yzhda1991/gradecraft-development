# Weights

  * Weights allow students to multiply their grade scores
  * In every course, all students receive a set number of "multipliers" that they can use to weight assignment types
  * Weights can only be applied at the assignment type level &mdash; meaning that all assignments in an assignment type will have the same weight
  * Students "spend" multipliers by setting the weight of assignment types
  * The weight of assignment types which have not yet been weighted by a user is always 1
  * Once a student sets the weight of an assignment type, the scores of all

For example:
In a course, students were given 6 multipliers. One student earned 50,000 points in an assignment type named "Essays". That student then set the weight of the "Essays" assignment type to 2, doubling the total number of points earned in the assignment type to 100,000. They are now left with 4 multipliers.

## How It Works

  * Stored in the AssignmentTypeWeight model, which contains the assignment type, student and weight
  * Enabled/disabled through the `student_weightable` attribute in the assignment type model
  * Rules of weight distribution are handled in the course model
  * Though the page where weights are added/removed (`/app/views/assignment_type_weights/index.html.haml`) does work, updating weights to the ones set on the page is currently disabled via `@update_weights`, which is set to false, in `API::Students::AssignmentTypesController`

## Customized Term

The term "weight" can be customized at the course level, with the default term being "Multiplier". See [[customized terms]] for more information.

## Weight-related attributes in Course model

*Note: this section will eventually be moved to the Course page*

These attributes control how and when students may distribute weights in a course.

  * `total_weights` - total weight that students are allowed to distribute to assignment types
  * `weights_close_at` - point in time at which students can no longer weight assignment types
  * `max_weights_per_assignment_type` - maximum weight that students can spend on a single assignment type
  * `max_assignment_types_weighted` - maximum number of assignment types that students may weight

## Directives

The following directives are used to display info in each assignment type row on the weight editing page. They are located in `/app/assets/javascripts/angular/directives/weights/`.

### weightedTotalPoints

  * displays the maximum number of points that a student could earn in the assignment type with the current weight that they have set

### weightsCoinWidget

  * area where weights/coins are added and removed from an assignment type, and where the current number of weights/coins are displayed
  * when a student clicks the button for adding coins, the directive scope's `increment()` method is called, and the assignment type's `student_weight` property is incremented by 1
  * when a student clicks the stack of coins, the directive scope's `decrement()` method is called, and the assignment type's `student_weight` property is decremented by 1
  * in both the `increment()` and `decrement()` methods, after `student_weight` is changed the AssignmentTypeService's `postAssignmentTypeWeight` method is called, which updates the assignment type's weight in the models if weight updating is enabled *see below*

### weightedEarnedPoints

* displays the student's current weight multiplied by the sum of the student's grades' `full_points` (raw points + adjustment points)

## Default Weights

Previously, there was a `default_weight` attribute in the Course model. When an assignment type with weights enabled was not yet weighted by a student, its weight was set to the value of its course's `default_weight` attribute. However, `default_weight` has now been removed, and an assignment type's default weight &mdash; that is, its weight before a student sets it themselves &mdash; is always 1, regardless of the course.

## Step by Step

1. A student can change the assignment type weight's at `/assignment_type_weights/`, where the current course's weighting rules are and where weights are added/removed, or alternatively, directly from the weights as displayed on the `predictor`.
2. In the index view, the page where weights are edited, `/app/assets/javascripts/angular/templates/weights/main.html.haml`, is included using angular and assigned the `WeightsCtrl` controller. The controller's `init` method is then called and passed in the student
3. In `init`, AssignmentTypeService's `getAssignmentTypes` method is called, where a GET request is sent to the index action of `API::Students::AssignmentTypesController`
5. The index action sends back JSON data from `/app/views/api/assignment_types/index.json.jbuilder`. Included in the JSON data is `meta.update_weights`, which is set to the controller's `@update_weights` (which is always false)
6. Back in `getAssignmentTypes`, the variables containing assignment types, terms and course weighting rules are set to the JSON data. The `weights` property of the empty object `update` is set to the JSON property `meta.update_weights`
7. Back in the main angular template, the assignment types from AssignmentTypeService are looped through, and the weight editing area is created
8. When the weights are changed in the weightsCoinWidget directive, AssignmentTypeService's `postAssignmentTypeWeight` is called
9. If `update.weights` is true (which it currently never is), a POST request is then sent to the create action of `API::AssignmentTypeWeightsController`, where the weight of the assignment type is updated

## Assignment Type Weight Model

Model where the weights that students set for assignment types are stored

### Associations

#### belongs_to

  * [[Student | users]] - when an Assignment Type Weight is saved, the Student's `updated_at` attribute will be set to the current date
  * [[Assignment Type | assignment types]]
  * [[Course | Courses]]

### Attributes

  * `weight` - weight of the assignment type for the student
