# Can be used independently as a service for managing both sort and filter
#   criteria or as part of the TableFilterService, which is designed for use
#   with the PaginationHelper directive, PaginationService
@gradecraft.factory 'SortableService', [() ->

  predicate = undefined  # the predicate(s) to sort on
  reverse = false  # sort reverse
  _filterCriteria = undefined # variable to store custom search criteria for a table
  _callback = undefined

  # The criteria to filter on
  filterCriteria = (criteria) ->
    if angular.isDefined(criteria) then _filterCriteria = criteria else _filterCriteria

  # A custom function that can be called after sorting the collection
  callback = (callback) ->
    if angular.isDefined(callback)
      _callback = callback
    else
      return null if not _callback?
      _callback()

  # Sets the sort criteria
  # If the sort criteria does not change, toggle the sort direction
  setSort = (predicate) ->
    if predicate == @predicate
      @reverse = !@reverse
    else
      @predicate = predicate
      @reverse = false
    callback() if callback?

  {
    filterCriteria: filterCriteria
    predicate: predicate
    reverse: reverse
    setSort: setSort
    callback: callback
  }
]
