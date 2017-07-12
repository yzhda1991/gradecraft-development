@gradecraft.directive 'assignmentMediaUploader', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/media_uploader.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)

      scope.removeMedia = ()->
        AssignmentService.removeMedia(@assignment.id)
  }
]

@gradecraft.directive('mediaUpload', ['$parse', 'AssignmentService', ($parse, AssignmentService)->
  return {
    restrict: 'A',
    scope: {
      assignmentId : "="
    }
    link: (scope, element, attrs)->
      model = $parse(attrs.mediaUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          AssignmentService.postMediaUpload(scope.assignmentId, element[0].files)
        )
      )
    }
])

