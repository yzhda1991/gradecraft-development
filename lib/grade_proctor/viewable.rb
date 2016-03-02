class GradeProctor
  module Viewable
    def viewable?(context)
      resource.is_released?
    end
  end
end
