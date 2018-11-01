gradecraft.directive 'attendanceEventAttributeCard', ['AttendanceService', '$timeout', (AttendanceService, $timeout) ->
  {
    scope:
      event: '='
      eventIndex: '='
    restrict: 'EA'
    templateUrl: 'attendance/_event_attribute_card.html'
    link: (scope, el, attr) ->
      scope.formErrors = []

      scope.queuePostAttendanceEvent = () ->
        AttendanceService.queuePostAttendanceEvent(@event)
        # clear out the error messages on the UI after 6 seconds
        $timeout(
          () -> scope.event.status = null
        , 6000)

      scope.validateDates = () ->
        scope.formErrors.length = 0
        openAtBeforeDueAt = moment(@event.open_at).isBefore(moment(@event.due_at))
        scope["event_#{@eventIndex}"].$setValidity("invalidDates", openAtBeforeDueAt)
        scope.formErrors.push("Open at date must be before due at date") if !openAtBeforeDueAt

      scope.saveStatusClass = () ->
        switch @event.status.state
          when "saving" then "save-pending"
          when "success" then "save-success"
          else "save-failure"

      scope.editAssignment = () ->
        return if !@event.id?
        AttendanceService.editAttendanceEvent(@event)

      scope.deleteEvent = () ->
        AttendanceService.deleteAttendanceEvent(@event)
  }
]
