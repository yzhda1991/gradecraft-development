@gradecraft.factory "PaginationService", [() ->

  options = {
    currentPage: 1
    pageSize: 25
    maxPages: undefined
  }

  # Use this to set the index with which to startFrom on the ng-repeat directive
  # e.g. { "ng-repeat"=>"item in collection" | startFrom: startFromIndex }
  startFromIndex = () -> (options.currentPage - 1) * options.pageSize

  setPageOffset = (number, increment=true) ->
    if increment is true then options.currentPage += number else options.currentPage -= number

  changePage = (number) -> options.currentPage = number

  setMaxPages = (max) ->
    options.maxPages = max
    options.currentPage = 1

  {
    options: options
    startFromIndex: startFromIndex
    setPageOffset: setPageOffset
    changePage: changePage
    setMaxPages: setMaxPages
  }
]
