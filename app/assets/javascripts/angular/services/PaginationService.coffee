@gradecraft.factory "PaginationService", [() ->

  options = {
    currentPage: 0
    pageSize: undefined
    maxPages: undefined
  }

  setPageOffset = (number, increment=true) ->
    if increment is true then options.currentPage += number else options.currentPage -= number

  changePage = (number) -> options.currentPage = number

  setMaxPages = (max) -> options.maxPages = max

  {
    options: options
    setPageOffset: setPageOffset
    changePage: changePage
    setMaxPages: setMaxPages
  }
]
