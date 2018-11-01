# common directive to create an icon with a tooltip on hover
# id is used for accessibility and should be unique per page
#
# example usage:
#   %tooltip-icon(id="{{assignmentType.id}}" glyph="paperclip" tip-text="Accepts Submissions")
#
gradecraft.directive 'tooltipIcon', [() ->
  return {
    scope: {
      assignmentId: "@",
      glyph: "@",
      tipText: "@"
    },
    templateUrl: 'common/tooltip_icon.html'
    link: (scope, elm, attrs) ->
      scope.tipId = "#{scope.tipText.toLowerCase().replace(/\W/g,'-')}-#{scope.assignmentId}"
      scope.iconClass = ()->
        "fa fa-fw fa-#{scope.glyph}"
  }
]
