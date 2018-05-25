@gradecraft.factory 'TableFilterService', ['$filter', ($filter) ->

  # the collection to filter on
  _original = []
  _filtered = []

  predicates = {
    teamId: undefined
    searchTerm: undefined
    customFilter: undefined
  }

  original = (arr) ->
    if angular.isDefined(arr)
      angular.copy(arr, _original)
      angular.copy(_original, _filtered)
    else
      _original

  filtered = (arr) ->
    if angular.isDefined(arr) then angular.copy(arr, _filtered) else _filtered

  filterByTerm = (term) ->
    predicates.searchTerm = { $: term }
    _updateFiltered()

  filterByExpression = (expression) ->
    predicates.customFilter = expression
    _updateFiltered()

  # updates the filtered collection based on the defined criteria
  _updateFiltered = () ->
    filtered = _original
    filtered = $filter('filter')(filtered, predicates.searchTerm) if predicates.searchTerm?
    filtered = $filter('filter')(filtered, predicates.customFilter) if predicates.customFilter?
    _filtered = filtered

  {
    original: original
    filtered: filtered
    predicates: predicates
    filterByTerm: filterByTerm
    filterByExpression: filterByExpression
  }
]
