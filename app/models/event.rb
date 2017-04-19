class Event < ActiveRecord::Base
  include Copyable
  include UploadsMedia

  belongs_to :course

  scope :with_dates, -> { where("events.due_at IS NOT NULL OR events.open_at IS NOT NULL") }

  # Check to make sure the event has a name before saving
  validates_presence_of :name

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes,
                               options: { prepend: { name: "Copy of "}}
    )
  end
end
