@gradecraft.factory 'SortableService', [() ->

  predicate = undefined  # the predicate(s) to sort on
  reverse = false  # sort reverse
  _filterCriteria = undefined # variable to store custom search criteria for a table

  filterCriteria = (criteria) ->
    if angular.isDefined(criteria) then _filterCriteria = criteria else _filterCriteria

  setSort = (predicate) ->
    if predicate == @predicate
      @reverse = !@reverse
    else
      @predicate = predicate
      @reverse = false

  {
    filterCriteria: filterCriteria
    predicate: predicate
    reverse: reverse
    setSort: setSort
  }
]
