# Iterates over Assignment Types, creating a collapsable section for each
# Populates each section with the Assignments for that Assignment Type

gradecraft.directive 'predictorSectionAssignmentTypes', [ 'PredictorService', (PredictorService)->

  return {
    templateUrl: 'predictor/assignment_types.html'
    link: (scope, el, attr)->

      scope.assignmentTypes = PredictorService.assignmentTypes
      scope.assignments = PredictorService.assignments

      scope.assignmentTypeHasAssignments = (assignmentType)->
        PredictorService.assignmentTypeHasAssignments(assignmentType)

      scope.assignmentTypeAtMaxPoints = (assignmentType)->
        PredictorService.assignmentTypeAtMaxPoints(assignmentType)

      scope.assignmentTypePointTotal = (assignmentType, includeWeights, includeCaps, includePredicted)->
        PredictorService.assignmentTypePointTotal(assignmentType, includeWeights, includeCaps, includePredicted)

      scope.assignmentTypePointExcess = (assignmentType)->
        PredictorService.assignmentTypePointExcess(assignmentType)
  }
]
