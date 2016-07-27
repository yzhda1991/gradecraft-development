# Manages Loading all assets for the Predictor Page on init

@gradecraft.controller 'PredictorCtrl', ['$scope', '$q', 'PredictorService', ($scope, $q, PredictorService) ->

  $scope.loading = true
  $scope.context = 'predictor'

  $scope.init = (student_id)->
    $scope.student_id = student_id
    $scope.services().then(()->
      $scope.loading = false
    )

  $scope.services = ()->
    promises = [PredictorService.getGradeSchemeElements(),
                PredictorService.getAssignments($scope.student_id),
                PredictorService.getAssignmentTypes($scope.student_id),
                PredictorService.getBadges($scope.student_id),
                PredictorService.getChallenges($scope.student_id)]
    return $q.all(promises)

  $scope.termFor = (article)->
    PredictorService.termFor(article)

  $scope.unusedWeightsRange = ()->
    PredictorService.unusedWeightsRange()

  $scope.weightsAvailable = ()->
    PredictorService.weightsAvailable()

]
