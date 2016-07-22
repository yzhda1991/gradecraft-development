# .student-panel-article

# Takes an Assignment, Badge, or Challenge and presents the detailed information
# in the student side panel.
@gradecraft.directive 'studentPanelArticle', ['PredictorService', 'StudentPanelService', (PredictorService, StudentPanelService)->

  return {
    restrict: 'C'
    scope: {
      article: '='
      icons: '='
    }
    templateUrl: 'student_panel/predictor_article/main.html'
    link: (scope, el, attr)->
      scope.articleTerm = ()->
        switch @article.type
          when "assignments" then PredictorService.termFor("assignment")
          when 'challenges' then PredictorService.termFor("challenge")
          when 'badges' then PredictorService.termFor("badge")
          else 'item'
      scope.focusArticle = ()->
        StudentPanelService.focusArticle()
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)
      scope.articleNoPoints = ()->
        PredictorService.articleNoPoints(@article)
  }
]
