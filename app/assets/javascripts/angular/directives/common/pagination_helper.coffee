@gradecraft.directive 'paginationHelper', ['PaginationService', (PaginationService) ->
  PaginationHelperCtrl = [() ->
    vm = this
    vm.options = PaginationService.options
    vm.setPageOffset = PaginationService.setPageOffset

    vm.currentPage = (page) ->
      if angular.isDefined(page)
        return vm.options.currentPage unless page in [1..vm.options.maxPages]
        vm.options.currentPage = page - 1
      else
        vm.options.currentPage + 1

    vm.changePage = (page) ->
      return if page == '..'
      PaginationService.changePage(page)

    vm.atMaxPage = () -> vm.currentPage() == vm.options.maxPages

    vm.selected = (pageNum) -> vm.currentPage() == pageNum

    # used for ng-repeat
    # converts an int to an array of length int, since ng-repeat requires a collection as a param
    vm.pageRange = (truncated=false) ->
      if truncated is true
        [0, 1, 2, '..', vm.options.maxPages - 2, vm.options.maxPages - 1]
      else
        range = [0..vm.options.maxPages]

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
  }
]
