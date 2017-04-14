@gradecraft.directive 'tooltipIcon', [() ->
  return {
    scope: {
      id: "@",
      glyph: "@",
      tipText: "@"
    },
    templateUrl: 'common/tooltip_icon.html'
    link: (scope, elm, attrs) ->
      scope.tipId = "#{scope.tipText.toLowerCase().replace(/\W/g,'-')}-#{scope.id}"
      scope.iconClass = ()->
        "fa fa-fw fa-#{scope.glyph}"
  }
]
