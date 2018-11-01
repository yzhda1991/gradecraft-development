# Defines icons listed under the article details.
# Each icon is turned on by by a boolean on the assignment or badge model with the same name.
# Icons are defined in the predictor service and looped through in the haml:
# "is_required", "is_late", "has_info", "is_locked", "has_been_unlocked", "is_a_condition", "group"
# example:
#   .predictor-article-icon{'ng-repeat'=>'icon in icons',
#     'icon-name'=>'icon', 'article'=>'assignment', 'article_type'=>'assignment'}
#
# This Does not handle locked/unlocked icons, which include lists conditions
# and is managed by /templates/student_panel/panel_article/condition_icons.html.haml

gradecraft.directive 'studentPanelArticleIcon',
[ 'StudentPanelService', (StudentPanelService)->

  return {
    scope: {
      iconName: '='
      article: '='
    }
    templateUrl: 'student_panel/predictor_article/icons.html'
    link: (scope, el, attr)->

      scope.articleTerm = ()->
        if @article.type == "assignments"
          StudentPanelService.termFor("assignment")
        else if @article.type == "badges"
          StudentPanelService.termFor("badge")
        else
          "item"

      scope.thresholdPoints = ()->
        @article.threshold_points

      scope.conditions = ()->
        @article.unlock_conditions

      scope.conditionsMet = ()->
        @article.unlocked_conditions

      scope.keys = ()->
        @article.unlock_keys

      scope.iconHtml = {
        is_late: {
          tooltip: 'This ' + scope.articleTerm() + ' is late!'
          icon: "fa-clock-o"
        }
        is_closed_without_submission: {
          tooltip: 'This ' + scope.articleTerm() + ' is no longer open for submissions'
          icon: "fa-ban"
        }
        is_required: {
          tooltip: 'This ' + scope.articleTerm() + ' is required!'
          icon: "fa-asterisk"
        }
        is_rubric_graded: {
          tooltip: 'This ' + scope.articleTerm() + ' is rubric graded'
          icon: "fa-th"
        }
        is_accepting_submissions: {
          tooltip: 'This ' + scope.articleTerm() + ' accepts submissions'
          icon: "fa-paperclip"
        }
        has_submission: {
          tooltip: 'You have submitted this ' + scope.articleTerm()
          icon: "fa-file"
        }
        has_threshold: {
          tooltip: 'You must earn ' + scope.thresholdPoints() + ' points or above for this ' + scope.articleTerm()
          icon: "fa-balance-scale"
        }
        is_earned_by_group: {
          tooltip: 'This ' + scope.articleTerm() + ' is earned by a group'
          icon: "fa-users"
        }
      }
  }
]
