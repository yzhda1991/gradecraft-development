# Debounce manager used to auto update items
#
# Each item is given a unique timeout stored by type and id.
# It can be cancelled and updated before fire,
# or fired immediately, cancelling the standing delayed event.

angular.module('helpers').factory('DebounceQueue', ['$timeout', ($timeout)->

  queueStore = {}
  TIME_TO_DELAY = 2500

  addEvent = (type, id, event, args=[], immediate=false)->
    return console.warn("Unable to add event:", type, "for:", id) if not type? || not id?

    if immediate is true
      cancelEvent(type, id)
      event.apply(null, args)
    else
      cancelEvent(type, id)
      queueStore[type + id] = $timeout(() ->
        event.apply(null, args)
      , TIME_TO_DELAY)

  cancelEvent = (type, id)->
    storeId = type + id
    return false if !queueStore[storeId]
    $timeout.cancel(queueStore[storeId])

  return {
    addEvent: addEvent
    cancelEvent: cancelEvent
  }
])

