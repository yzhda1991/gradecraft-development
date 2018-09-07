require "mongoid"

class Analytics::Event
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :event_type, type: String
  field :created_at, type: DateTime

  validates :event_type, :created_at, presence: true

  after_create do |event|
    if aggregates = Analytics.configuration.event_aggregates.stringify_keys[event.event_type]
      aggregates.each do |a|
        Rails.logger.debug "incrementing aggregate type: #{a}"
        a.incr(event)
      end
    end
  end
end
