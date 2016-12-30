class Event < ActiveRecord::Base
  include UploadsMedia

  belongs_to :course, touch: true

  scope :with_dates, -> { where("events.due_at IS NOT NULL OR events.open_at IS NOT NULL") }

  # Check to make sure the event has a name before saving
  validates_presence_of :name
end
