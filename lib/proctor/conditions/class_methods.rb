module Proctor
  module Conditions
    module ClassMethods
      def defer_to_proctor(*deferred_methods)
        deferred_methods.each do |method_name|
          define_method(method_name) { proctor.send(method_name) }
        end
      end
    end
  end
end
