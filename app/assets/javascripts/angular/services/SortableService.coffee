@gradecraft.factory 'SortableService', [() ->

  predicate = undefined  # the predicate(s) to sort on
  reverse = false  # sort reverse

  setSort = (predicate) ->
    if predicate == @predicate
      @reverse = !@reverse
    else
      @predicate = predicate
      @reverse = false

  {
    predicate: predicate
    reverse: reverse
    setSort: setSort
  }
]
