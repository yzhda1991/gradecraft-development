# Iterates through levels in a criterion

@gradecraft.directive 'courseCreationProgressBar', [() ->

  return {
    templateUrl: 'courses/creation_progress_bar.html'
    scope: {
      items: "="
    }
    link: (scope, el, attr)->

      totalItems = ()->
        scope.items.length

      itemsComplete = ()->
        _.reject(scope.items, {done: false}).length

      scope.barWidth = ()->
        itemsComplete() / totalItems() * 100 + "%"

      scope.barTitle = ()->
        "#{itemsComplete()}/#{totalItems()} items complete!"

  }
]
