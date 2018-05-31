@gradecraft.directive 'paginationHelper', ['PaginationService', (PaginationService) ->
  PaginationHelperCtrl = [() ->
    vm = this
    vm.options = PaginationService.options
    vm.setPageOffset = PaginationService.setPageOffset

    vm.changePage = (page) ->
      return if page == '..'
      PaginationService.changePage(page)

    vm.changePageSize = (size) ->
      vm.options.pageSize = size
      pages = _.chunk(vm.collection, size)
      PaginationService.setMaxPages(pages.length)

    vm.hasItems = () -> vm.collection.length > 0
    vm.atMaxPage = () -> vm.options.currentPage >= vm.options.maxPages

    vm.selected = (pageNum) -> vm.options.currentPage == pageNum

    # used for ng-repeat
    # converts an int to an array of length int, since ng-repeat requires a collection as a param
    vm.pageRange = (truncated=false) ->
      if truncated is true
        [1, 2, 3, '..', vm.options.maxPages - 1, vm.options.maxPages]
      else
        range = if vm.options.maxPages == 1 then [1] else [1..vm.options.maxPages]
  ]

  {
    scope:
      collection: '='
    bindToController: true
    controller: PaginationHelperCtrl
    controllerAs: 'paginationHelperCtrl'
    templateUrl: 'common/pagination_helper.html'
    link: (scope, elem, attrs) ->
      scope.$watch('paginationHelperCtrl.collection', (newValue, oldValue) ->
        pages = _.chunk(newValue, PaginationService.options.pageSize)
        PaginationService.setMaxPages(pages.length)
      )
  }
]
