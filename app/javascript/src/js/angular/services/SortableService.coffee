@gradecraft.factory 'SortableService', [() ->

  predicate = undefined  # the predicate(s) to sort on
  reverse = false  # sort reverse
  _filterCriteria = undefined # variable to store custom search criteria for a table
  _predicateType = undefined

  filterCriteria = (criteria) ->
    if angular.isDefined(criteria) then _filterCriteria = criteria else _filterCriteria

  # if sorting on an attribute (string, e.g. 'first_name'), only pass in the first argument
  # else, specify a name for the predicate as well as the expression used for the sort
  # see documentation for orderBy usage in an ngRepeat for additional details
  setSort = (predicate, expression=null) ->
    if predicate == @_predicateType
      @reverse = !@reverse
    else
      @predicate = if expression? then expression else predicate
      @_predicateType = predicate
      @reverse = false

  setDirection = () -> @reverse = !@reverse

  isCurrentPredicate = (predicate) -> @_predicateType == predicate

  {
    filterCriteria: filterCriteria
    predicate: predicate
    reverse: reverse
    setSort: setSort
    setDirection: setDirection
    isCurrentPredicate: isCurrentPredicate
  }
]
