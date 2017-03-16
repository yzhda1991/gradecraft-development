# Student Predicted Grades

One of the core features of Gradecraft is the ability for students to predict grades for all the available [[Assignments]], [[Challenges]], and [[Badges]] in a course, and to see what their final grade will be based on these Predictions. All of these predictions are managed on a single page, with each predictable item represented by a [widget](#widgets).

## Predictor Page, Student and Faculty viewing

The predictor page is served through the Student controller. In reality there are three places where the predictor page is viewable.

### Student View

The primary predictor route is from the student's perspective at `/predictor`. This is the full featured predictor, and will show the predictor for the current course.

### Faculty Views

Faculty can view any student's predictor at `students/:id/predictor`. This view is used when a professor needs to help a student access where they are in the course, and make recommendations for what they should focus on.  One important piece of data is missing from this view: all actual predictions! This is because research shows knowing student's predictions can influence the grading of assignments. Instead all predictions are shows as zero. Visible Graded items, and the student's Assignment Weights show up as they would in the student view.

Faculty also have a predictor preview at `/predictor`. This view is used to check that items show up in the predictor as expected. No student data is loaded, so all items are either shows with zero points predicted, or zero points earned if the item is past due. Assignment weights, if available, show up as unused.

## Page Organization

### Points Graph

The top of the page contains a bar graph which shows the points the student has already earned, and the additional points the student has predicted.

### Collapsible Headers

Predicable Items are organized under collapsible headers, each of which displays the total for all it's child items. There is one main header showing the total for all items and the predicted final grade name and level. Underneath is a header for each [[Assignment Type | Assignment Types]], one for Badges if the course has [[Badges]], and one for Challenges if the course has [[Challenges]].

### Widgets

There are several styles of Widgets for item presentation in the Predictor, organized under Assignment Types, Badges, and Challenges

#### Binary switch

Pass/Fail assignments, and Badges which can only be earned once, are represented with a binary switch

![assignment widget with slider](images/predictor_switch.png)


#### Sliders

Assignments and Challenges which are graded on a spectrum are represented with a slider

![assignment widget with slider](images/predictor_slider.png)

#### Slider with stops

Assignments and Challenges with Score Levels. Looks like a normal slider, but snaps to score levels and the name of the score level shows up underneath

![assignment widget with score levels](images/predictor_slider_score_levels.png)

#### Counters

Badges which can be earned multiple times.

![assignment widget with slider](images/predictor_counter.png)

#### Visible Graded Items

Items that have been graded and are [[ visible to the student | Grade Status ]] show up as a non-interactive percentage: points earned / total points

![assignment widget with slider](images/predictor_earned.png)

##### Grade State or Interactive Component?

In order to determine whether a widget shows a grade or slider, we use the following logic path. Note that this is managed both from the Angular front end, as well as the [`predicted_grade_serializer`](https://github.com/UM-USElab/gradecraft-development/blob/master/app/serializers/predicted_grade_serializer.rb)

    raw_points is nil -> false
      grade is student visible? -> true
        = show grade
      grade is student visible? -> false
        = show predictor-slider

    raw_points is nil -> true
      assignment accepts_submissions? -> false
        = show predictor-slider

      assignment accepts_submissions? -> true
        submissions_have_closed? -> false
          = show predictor-slider

        submissions_have_closed? -> true
          student has made a submission -> true
            = show predictor-slider
          student has made a submission -> false
            = show GRADE = 0

### Icons

All predictor widgets have a bar which displays icons with additional hover information. All possible icons are defined in the [predictor service](#predictor-service). They are sent as booleans on the predictable item. If true, the icon will be presented on the item, with additional information handled by the [predictorArticleIcon Directive](#predictor-directive)

Icons include:

  * is_required
  * is_late
  * has_info -- adds the `item.description ` as hover info
  * is_locked -- adds the `unlock_conditions` as hover info
  * has_been_unlocked -- adds the `item.unlock_conditions` as hover info
  * is_a_condition -- adds the `item.unlock_keys` as hover info
  * is_a_group_assignment -- [TODO: has not been implemented]

## Rails Components

### JSON Services

Once the predictor page loads the data for the predictor is gathered from several JSON endpoints within Gradecraft. Each of these endpoints is routed from a predictor_data method within the appropriate controller. They include the following:

  * Assignments (including the Student's Grade, Student's prediction and Score Levels).
  * Badges (including the student's prediction)
  * Challenges (including the student's prediction)
  * Assignment Types
  * Grade Scheme Elements (All [[Grade Scheme Elements]] within the [[Course | Courses]], and the total points for the [[Course | Courses]] )
  * Weights

### Update Services

Prediction data is persisted on a per-action basis through the following routes:

* Predicted Assignment Grades - `GradesController#predict_score` (TODO: change to `predict_points`)
* Predicted Badges (times earned) - `BadgesController#predict_times_earned`
* Predicted Challenges (points earned) - `ChallengesController#predict_points_earned`
* Weights - `AssigmentTypeWeightsController#update`

## Angular Components

### Predictor Service

Manages all the GET and POST requests, and is included in directives to bring additional data into scope.

### Predictor Controller

Handles much of the scope level logic for assignments, badges, challenges, and builds the points earned graph with D3. Also handles the [slider widgets](#sliders) and [slider widgets with score levels](#slider-with-stops)

### Predictor Directive

Contains all directives for the predictor in one file:

  * `predictorArticleIcon` - adds all stateful [icons](#icons) to assignments and badges (info, required, late etc.)
  * `predictorBinarySwitch` - creates the [binary switch widget](#binary-switch).

  * `predictorCounterSwitch` - creates the [counter widget](#counters).
  * `predictorAssignmentTypeWeights` - Adds the weight coins to the Assignment type, and the weighted total

### Templates

Templates include:

  * assignment_types - creates the [collapsible header](#collapsible-headers) for each assignment type
  * assignments - creates an interactive [widget](#widgets) for each assignment
  * badges - creates an interactive [widget](#widgets) for each badge
  * challenges - creates an interactive [widget](#widgets) for each challenge
  * counter - creates a [counter widget](#counters), from the predictorCounterSwitch directive
  * graphic - creates the [bar graph](#points-graph) on the top of the page
  * icons - iterates though the icons in
  * main - the main page
  * switch
  * weights
