# Common directive for rendering a basic search input field
# that sets the sort criteria in the SortableService
gradecraft.directive 'sortableSearchInput', ['SortableService', (SortableService) ->
  SortableSearchInputCtrl = [() ->
    vm = this
    vm.searchCriteria = SortableService.filterCriteria
  ]

  {
    bindToController: true
    controller: SortableSearchInputCtrl
    controllerAs: 'ssInputCtrl'
    templateUrl: 'common/sortable_search_input.html'
  }
]
