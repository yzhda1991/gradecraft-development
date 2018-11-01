# Creates a checklist during course creation for Faculty to check off as they
# design the course.

gradecraft.directive 'courseCreationChecklist', ['$q', 'CourseService', ($q, CourseService) ->
  CourseCreationController = [()->
    vmChecklist = this
    vmChecklist.loading = true
    vmChecklist.CourseService = CourseService

    checklistServices().then(()->
      vmChecklist.loading = false
    )

    vmChecklist.inputId = (item)->
      "course_#{vmChecklist.courseId}-#{item.item}"

    vmChecklist.termFor = (term)->
      vmChecklist.CourseService.termFor(term)

    vmChecklist.checklistItems = ()->
      vmChecklist.CourseService.creationChecklist()

    vmChecklist.toggleChecklistItem = (item)->
      item.done = !item.done
      CourseService.updateCourseCreationItem(item)
  ]

  checklistServices = ()->
    promises = [
      CourseService.getCourseCreation()
    ]
    return $q.all(promises)

  return {
    bindToController: true,
    controller: CourseCreationController,
    controllerAs: 'vmChecklist',
    templateUrl: 'courses/creation_checklist.html',
  }
]
