@gradecraft.directive 'paginationHelper', ['PaginationService', (PaginationService) ->
  PaginationHelperCtrl = [() ->
    vm = this
    vm.options = PaginationService.options
    vm.setPageOffset = PaginationService.setPageOffset

    vm.changePage = (page) ->
      return if page == '..'
      PaginationService.changePage(page)

    vm.atMaxPage = () -> vm.options.currentPage >= vm.options.maxPages

    vm.selected = (pageNum) -> vm.options.currentPage == pageNum

    # used for ng-repeat
    # converts an int to an array of length int, since ng-repeat requires a collection as a param
    vm.pageRange = (truncated=false) ->
      if truncated is true
        [1, 2, 3, '..', vm.options.maxPages - 1, vm.options.maxPages]
      else
        range = if vm.options.maxPages == 1 then [1] else [1..vm.options.maxPages]

    vm.options.pageSize = @pageSize
  ]

  {
    scope:
      pageSize: '='
      collection: '='
    bindToController: true
    controller: PaginationHelperCtrl
    controllerAs: 'paginationHelperCtrl'
    templateUrl: 'common/pagination_helper.html'
    link: (scope, elem, attrs) ->
      scope.$watch('paginationHelperCtrl.pageSize', (newValue, oldValue) ->
        return unless newValue?
        pages = _.chunk(scope.paginationHelperCtrl.collection, newValue)
        PaginationService.setMaxPages(pages.length)
      )
      scope.$watch('paginationHelperCtrl.collection()', (newValue, oldValue) ->
        pages = _.chunk(newValue, scope.paginationHelperCtrl.pageSize)
        PaginationService.setMaxPages(pages.length)
      )
  }
]
