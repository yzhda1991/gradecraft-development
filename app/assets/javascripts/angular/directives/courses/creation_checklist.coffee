# Creates a checklist during course creation for Faculty to check off as they
# design the course.

@gradecraft.directive 'courseCreationChecklist', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      courseId: "="
    }
    templateUrl: 'courses/creation_checklist.html',
    link: (scope, el, attr)->
      console.log("sam i am");
  }
]
