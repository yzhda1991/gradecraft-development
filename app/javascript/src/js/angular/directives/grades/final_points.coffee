# display calculated final_points

gradecraft.directive 'gradeFinalPoints', [() ->

  return {
    templateUrl: 'grades/final_points.html'
    scope: {
      grade: "="
    }
  }
]
