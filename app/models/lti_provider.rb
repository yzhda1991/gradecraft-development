class LTIProvider < ApplicationRecord

  def to_param
    uid
  end
end
