# Creates a checklist during course creation for Faculty to check off as they
# design the course.

@gradecraft.directive 'courseCreationChecklist', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      courseId: "="
    }
    templateUrl: 'courses/creation_checklist.html',
    link: (scope, el, attr)->
      scope.checklistItems = [
        "Course Settings",
        "Attendance",
        "Assignments",
        "Calendar Events",
        "Set Up Teaching Term",
        "Import Roster"
      ]

      scope.toggleChecklistItem = (item)->
        debugger
        console.log(item)
  }
]
