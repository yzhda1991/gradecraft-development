class Timeline
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def assignment_events
    course.assignments.timelineable.with_dates
  end

  def event_events
    course.events.with_dates
  end

  def challenge_events
    course.challenges.with_dates if course.has_team_challenges?
  end

  def events
    @events ||= [
      assignment_events.to_a,
      challenge_events.to_a,
      event_events.to_a
    ].flatten
  end
end
