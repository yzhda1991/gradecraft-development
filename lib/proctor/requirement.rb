module Proctor
  # all we need to do is subclass Condition because
  # the behaviors are the same. We may want to add this later
  # but for better nomenclature this should be called an Override for now
  # citing how this is going to be handled.
  #
  class Requirement < Proctor::Condition
  end
end
