class CopyLog < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :course
  validates_presence_of :log

  def to_hash
    eval self.log
  end

  def parse_log(hash_log)
    self.log = hash_log.to_s
  end
end
