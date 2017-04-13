@gradecraft.directive 'tooltip', [() ->
  return {
    scope: {
      id: "@",
      glyph: "@",
      tipText: "@"
    },
    templateUrl: 'common/tooltip.html'
    link: (scope, elm, attrs) ->
      scope.tipId = "#{scope.tipText.toLowerCase().replace(/\W/g,'-')}-#{scope.id}"
      scope.iconClass = ()->
        "fa fa-fw fa-#{scope.glyph}"
  }
]
