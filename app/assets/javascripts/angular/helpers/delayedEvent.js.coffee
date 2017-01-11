# Debounce manager used to auto update items
#
# Each item is given a unique timeout stored by type and id.
# It can be cancelled and updated before fire,
# or fired immediately, cancelling the standing delayed event.

angular.module('helpers').factory('DelayedEvent', ['$timeout', ($timeout)->

  queueStore = {}
  TIME_TO_DELAY = 3500

  addQueue = (type, id, event, args=[], immediate=false)->
    queueStore[type] = queueStore[type] || {}

    if immediate is true
      cancelQueue(type, id)
      event.apply(null, args)
    else
      cancelQueue(type, id)
      queueStore[type][id.to_s] = $timeout(() ->
        event.apply(null, args)
      , TIME_TO_DELAY)


  cancelQueue = (type, id)->
    return false if !queueStore[type]
    $timeout.cancel(queueStore[type][id.to_s])

  return {
    addQueue: addQueue
    cancelQueue: cancelQueue
  }
])

