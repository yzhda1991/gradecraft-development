'use strict'

angular.module('helpers')
  .factory('EventHelper', ()->
    {
      killEvent: (event)->
        event.preventDefault()
        event.stopPropagation()
    }
  )
