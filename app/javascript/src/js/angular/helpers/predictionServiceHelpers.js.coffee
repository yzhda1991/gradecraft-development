# Common CRUD operations for Prediction Article Services
angular.module('helpers').factory('GradeCraftPredictionAPI', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI)->

  createPrediction = (article, url, requestParams)->
    $http.post(url, requestParams).then(
      (response)-> # success
        if response.status == 201
          article.prediction = response.data.data.attributes
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  updatePrediction = (article, url, requestParams)->
    $http.put(url, requestParams).then(
      (response)-> # success
        if response.status == 200
          article.prediction = response.data.data.attributes
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  return {
    createPrediction: createPrediction
    updatePrediction: updatePrediction
  }
])

