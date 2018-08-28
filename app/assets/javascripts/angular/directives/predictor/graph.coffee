# Renders the graph fixed to the top of the predictor page
# Must not render until Grade Scheme Elements are loaded,
# to position high and low point ranges.

@gradecraft.directive 'predictorGraph', [ '$window', 'PredictorService', 'DebounceQueue',  ($window, PredictorService, DebounceQueue)->

  return {
    templateUrl: 'predictor/graph.html'

    link: (scope, el, attr)->

      scope.allPointsEarned = ()->
        PredictorService.allPointsEarned()

      scope.allPointsPredicted = ()->
        PredictorService.allPointsPredicted()

      scope.lockedPointsPredicted = ()->
        PredictorService.lockedPointsPredicted()

      scope.lockedGradeSchemeElementsPresent = ()->
        PredictorService.lockedGradeSchemeElementsPresent()

      scope.predictedGradeLevel = ()->
        PredictorService.predictedGradeLevel()

      # Dertermine the bounds and the scale for postioning the graph elements
      scope.GraphsStats = ()->
        # add 10% to the graph above the highest grade
        totalPoints = PredictorService.totalPoints() * 1.1
        # The graph width must be calculated off of the spacer, since the graph itself is a fixed width
        width = parseInt(d3.select("#predictor-graph-section").style("width")) - 20
        height = parseInt(d3.select("#predictor-graph-svg").style("height"))
        stats = {
          width: width
          height: height
          padding: 10
          # Maximum possible points for the course
          totalPoints: totalPoints
          #scale for placing elements along the x axis
          scale: d3.scaleLinear().domain([0,totalPoints]).range([0,width])
        }

      # Don't let the hover boxes with grades info fall off the right side
      scope.gradeLevelPosition = (scale,lowRange,width,padding)->
        alignWithTickMark = 3.5
        position = scale(lowRange)
        textWidth = angular.element(".grade_scheme-label-" + lowRange)[0].getBBox().width
        if position < padding
          return alignWithTickMark
        else if position + textWidth > width
          return width - textWidth
        else
          return position + alignWithTickMark

      # Indicate Locked Grade Scheme elements by coloring them red
      scope.pinColor = (gse)->
        if gse.is_locked
          "#D1495B" #red for locked GSE
        else
          "000000" #black

      scope.pinTextColor = (gse)->
        if gse.is_locked
          "#D1495B" #red
        else
          "#68A127" #green


      # Loads the grade points values and corresponding grade levels name/letter-grade into the predictor graph
      # Renders D3 object
      scope.renderGradeLevelGraph = ()->
        svg = d3.select("#svg-grade-levels")
        stats = scope.GraphsStats()
        padding = stats.padding
        scale = stats.scale
        g = svg.selectAll('g').data(PredictorService.gradeSchemeElements).enter().append('g')
                .attr("transform", (gse)->
                  "translate(" + (scale(gse.lowest_points) + padding) + "," + 25 + " )")
                .on("mouseover", (gse)->
                  d3.select(".grade_scheme-label-" + gse.lowest_points).style("visibility", "visible")
                  d3.select(".grade_scheme-pointer-" + gse.lowest_points)
                    .attr("transform","scale(4) translate(-1.5,-3)")
                    .attr("fill", (gse)-> scope.pinTextColor(gse))
                )
                .on("mouseout", (gse)->
                  d3.select(".grade_scheme-label-" + gse.lowest_points).style("visibility", "hidden")
                  d3.select(".grade_scheme-pointer-" + gse.lowest_points)
                    .attr("transform","scale(2) translate(-1.5,0)")
                    .attr("fill", (gse)-> scope.pinColor(gse))
                )
        g.append("path")
          .attr("d", "M3,2.492c0,1.392-1.5,4.48-1.5,4.48S0,3.884,0,2.492c0-1.392,0.671-2.52,1.5-2.52S3,1.101,3,2.492z")
          .attr("class",(gse)-> "grade_scheme-pointer-" + gse.lowest_points)
          # move the pins over so the point is on the right value
          .attr("transform","scale(2) translate(-1.5,0)")
          .attr("fill", (gse)-> scope.pinColor(gse))
        txt = d3.select("#svg-grade-level-text").selectAll('g').data(PredictorService.gradeSchemeElements).enter()
                .append('g')
                .attr("class", (gse)->
                  "grade_scheme-label-" + gse.lowest_points)
                .style("visibility", "hidden")
        txt.append('text')
          .text( (gse)-> gse.name)
          .attr("y","15")
          .attr("x",padding)
          .attr("fill", "#FFFFFF")
        txt.insert("rect",":first-child")
          .attr("width", (gse)->
              angular.element(".grade_scheme-label-" + gse.lowest_points)[0].getBBox().width + (padding * 2)
            )
          .attr("height", 22)
          .attr("fill", (gse)-> scope.pinTextColor(gse))
        txt.attr("transform", (gse)->
          "translate(" + scope.gradeLevelPosition(scale,gse.lowest_points,stats.width,padding) + "," + 0 + ")")
        graph = d3.select("svg").append("g")
          .classed("grade-point-axis", true)
          .attr("transform", ()->
            "translate(" + padding + "," + (65) + ")"
          ).call(d3.axisBottom(scale))

      # Calculetes width for Earned Points (green) bar
      scope.svgEarnedBarWidth = ()->
        width = scope.GraphsStats().scale(PredictorService.allPointsEarned())
        width = width || 0

      # Calculetes width for Predicted Points (blue) bar, minus the locked points
      scope.svgPredictedBarWidth = ()->
        width = scope.GraphsStats().scale(PredictorService.allPointsPredicted() - PredictorService.lockedPointsPredicted())
        width = width || 0

      # Calculates width for Predicted Locked Points (light-blue) bar
      scope.svgPredictedLockedBarWidth = ()->
        width = scope.GraphsStats().scale(PredictorService.allPointsPredicted())
        width = width || 0

      # render!
      scope.renderGradeLevelGraph()

      # Update graph x-axis for redraw
      scope.updateGradeLevelGraph = ()->
        d3.select("#predictor-graph-section svg .grade-point-axis").remove()
        d3.select('#svg-grade-levels').selectAll('g').remove()
        d3.select("#svg-grade-level-text").selectAll('g').remove()
        scope.renderGradeLevelGraph()
        d3.select("#svg-graph-points-earned").attr("width", scope.svgEarnedBarWidth())
        d3.select("#svg-graph-points-predicted-locked").attr("width", scope.svgPredictedLockedBarWidth())
        d3.select("#svg-graph-points-predicted").attr("width", scope.svgPredictedBarWidth())


      # re-render on window resize end!
      angular.element($window).on 'resize', ->
        DebounceQueue.addEvent(
          "graphs", 'predictorGraph', scope.updateGradeLevelGraph, [], 250
          )
  }
]
