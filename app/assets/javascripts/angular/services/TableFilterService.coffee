# Extends sort and filter logic to any given collection
# Maintains a filtered collection for use with PaginationHelper directive,
#   PaginationService
@gradecraft.factory 'TableFilterService', ['SortableService', '$filter', (SortableService, $filter) ->

  collections = {
    original: []
    filtered: []
  }

  predicates = {
    teamId: undefined
    searchTerm: undefined
    customFilter: undefined
  }

  setCollections = (arr) ->
    angular.copy(arr, collections.original)
    angular.copy(arr, collections.filtered)

  filterByTerm = (term) ->
    predicates.searchTerm = { $: term }
    _updateFiltered()

  filterByExpression = (expression) ->
    predicates.customFilter = expression
    _updateFiltered()

  # updates the filtered collection based on the defined criteria
  _updateFiltered = () ->
    filtered = collections.original
    filtered = $filter('filter')(filtered, predicates.searchTerm) if predicates.searchTerm?
    filtered = $filter('filter')(filtered, predicates.customFilter) if predicates.customFilter?
    filtered = $filter('orderBy')(filtered, SortableService.predicate, SortableService.reverse) if SortableService.predicate?
    collections.filtered = filtered

  # trigger an update on the collection each time the sort ordering changes
  SortableService.callback(_updateFiltered)

  {
    setCollections: setCollections
    collections: collections
    predicates: predicates
    filterByTerm: filterByTerm
    filterByExpression: filterByExpression
  }
]
