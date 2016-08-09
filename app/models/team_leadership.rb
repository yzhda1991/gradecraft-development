class TeamLeadership < ActiveRecord::Base
  belongs_to :team
  belongs_to :leader, class_name: "User"

  validates_presence_of :team, :leader
end
