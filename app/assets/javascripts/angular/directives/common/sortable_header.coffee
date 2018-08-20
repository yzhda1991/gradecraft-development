# Generic sortable directive for making table headers sortable

# Usage:
#   Add .sortable-header class
#   Include data-sortable-header-text attribute with the text of the header as the value
#   Include data-sortable-predicate attribute with the name of the model value to be sorted on

# e.g.
#   %th.sortable-header{"data-sortable-header-text"=>"First Name", "data-sortable-predicate"=>"first_name"}
@gradecraft.directive 'sortableHeader', ['SortableService', (SortableService) ->
  SortableHeader = [() ->
    vm = this

    vm.setSort = () -> SortableService.setSort(@sortablePredicate, @sortableFn())
    vm.currentPredicate = () -> SortableService.isCurrentPredicate(@sortablePredicate)
    vm.icon = () -> if SortableService.reverse is true then "fa-caret-up" else "fa-caret-down"
  ]

  {
    scope:
      sortableHeaderText: '@'  # the text for the header link
      sortablePredicate: '@'  # the predicate(s) to sort on
      sortableFn: '&'
    restrict: 'C'
    bindToController: true
    controller: SortableHeader
    controllerAs: 'sortableHeaderCtrl'
    templateUrl: 'common/sortable_header.html'
  }
]
