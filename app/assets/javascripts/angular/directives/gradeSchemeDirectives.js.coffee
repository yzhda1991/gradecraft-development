# I appreciate the virtues of a directive-oriented implementation but in this
# context it's a lot more involved to re-model the ng-change functionality
# through the directive rather than through the controller.
#
# The controller for our grade scheme elements are very sparse, and since scope
# is central to controller behavior it's much different than the routing-
# oriented behaviors we see in Rails.
#
# @gradecraft.directive 'lowRange', ()->
#   restrict: 'C'
#   link: (scope, elem, attrs, ctrls) ->
#
#     # this does not approximate ng-change, but rather calls and digests the
#     # results of this function after the target element has been blurred
#     #
#     elem.bind 'change', ->
#       # get the index of the current grade scheme element and find the next
#       # element relative to that grade scheme row as well as the current one
#       nextElement = scope.grade_scheme_elements[attrs.index + 1]
#       currentElement = scope.grade_scheme_elements[attrs.index]
#
#       if nextElement
#         if currentElement.lowest_points > 0
#           nextElement.highest_points = currentElement.lowest_points - 1
#         else
#           nextElement.highest_points = null
#
#         scope.$digest()
#
#       return
#
# @gradecraft.directive 'highRange', ()->
#   restrict: 'C'
#   link: (scope, elem, attrs, ctrls) ->
#
#     # this does not approximate ng-change, but rather calls and digests the
#     # results of this function after the target element has been blurred
#     #
#     elem.bind 'change', ->
#       # get the index of the current grade scheme element and find the previous
#       # element relative to that grade scheme row as well as the current one
#       previousElement = scope.grade_scheme_elements[attrs.index - 1]
#       currentElement = scope.grade_scheme_elements[attrs.index]
#
#       if previousElement
#         if currentElement.highest_points
#           previousElement.lowest_points = currentElement.highest_points + 1
#         else
#           previousElement.lowest_points = null
#
#         scope.$digest()
#
#       return
