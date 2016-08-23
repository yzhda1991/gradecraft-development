# Manages Loading all assets for the Predictor Page on init

@gradecraft.controller 'PredictorCtrl', ['$scope', '$q', 'PredictorService', 'StudentPanelService', ($scope, $q, PredictorService, StudentPanelService) ->

  $scope.loading = true

  $scope.init = (student_id)->
    $scope.student_id = student_id
    $scope.services().then(()->
      $scope.loading = false
      StudentPanelService.changeFocusArticle(PredictorService.assignments[0])
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

  $scope.weights = PredictorService.weights

  $scope.unusedWeightsRange = ()->
    PredictorService.unusedWeightsRange()

  $scope.weightsAvailable = ()->
    PredictorService.weightsAvailable()

]
