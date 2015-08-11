class Announcement < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :course

  default_scope { order "created_at DESC" }
end
