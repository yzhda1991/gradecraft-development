class Event < ActiveRecord::Base

  attr_accessible :course_id, :name, :description, :media, :media_credit, :thumbnail, :media_caption, :open_at,
  :due_at, :remove_media, :remove_thumbnail

  mount_uploader :media, EventMediaUploader
  mount_uploader :thumbnail, EventThumbnailUploader

  belongs_to :course, touch: true

  # Check to make sure the event has a name before saving
  validates_presence_of :name

end
