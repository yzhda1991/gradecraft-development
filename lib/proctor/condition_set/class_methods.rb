module Proctor
  module ConditionSet
    module Defer
      # this will help our conditions set defer specific methods to the included
      # Proctor class so we don't have to re-define all of these relationships
      # in the conditions set in order to make the comparison
      #
      # Example:
      #
      # class FooProctor
      #   def foo_file
      #     "this is the foo file!!"
      #   end
      # end
      #
      # class FooConditionSet
      #   include Proctor::ConditionSet
      # end
      #
      # condition_set = FooConditionSet.new(proctor: FooProctor.new)
      # condition_set.foo_file
      # => "this is the foo file!!"
      #
      def defer_to_proctor(*deferred_methods)
        deferred_methods.each do |method_name|
          define_method(method_name) { proctor.send(method_name) }
        end
      end
    end
  end
end
