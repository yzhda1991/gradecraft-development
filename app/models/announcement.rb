class Announcement < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :course

  attr_accessible :body

  default_scope { order "created_at DESC" }

  def abstract(words=25)
    body.split(/\s+/)[0..words].join(" ").strip
  end
end
