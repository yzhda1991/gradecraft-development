# Iterates through levels in a criterion

@gradecraft.directive 'courseCreationProgressBar', ['CourseService', (CourseService) ->

  return {
    templateUrl: 'courses/creation_progress_bar.html'

    link: (scope, el, attr)->

      totalItems = ()->
        CourseService.creationChecklist().length

      itemsComplete = ()->
        _.reject(CourseService.creationChecklist(), {done: false}).length

      scope.barWidth = ()->
        itemsComplete() / totalItems() * 100 + "%"

      scope.barTitle = ()->
        "#{itemsComplete()}/#{totalItems()} items complete!"

  }
]
