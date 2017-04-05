
@gradecraft.directive 'assignmentSetting', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      #assignmentId: "="
    }
    templateUrl: 'assignments/assignment_settings.html',
    link: (scope, el, attr)->
      console.log("sam i am");
      scope.assignment = ()->
        #AssignmentService.assignment() where id == id
  }
]

