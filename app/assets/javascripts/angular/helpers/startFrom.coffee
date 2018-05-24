angular.module('helpers').filter('startFrom', () ->
  (input, start) ->
    start = +start # parse to int
    input.slice(start)
)
