# Takes an Assignment, Badge, or Challenge and presents the detailed information
# in the student side panel.
gradecraft.directive 'studentPanelArticle',
['StudentPanelService', "PredictorService", (StudentPanelService, PredictorService)->

  return {
    scope: {
      article: '='
      icons: '='
    }
    templateUrl: 'student_panel/panel_article/main.html'
    link: (scope, el, attr)->
      scope.articleTerm = ()->
        switch @article.type
          when "assignments" then StudentPanelService.termFor("assignment")
          when 'challenges' then StudentPanelService.termFor("challenge")
          when 'badges' then StudentPanelService.termFor("badge")
          else 'item'
      scope.focusArticle = ()->
        StudentPanelService.focusArticle()
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)
      scope.articleNoPoints = ()->
        PredictorService.articleNoPoints(@article)
  }
]
