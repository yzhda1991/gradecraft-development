module ModelAddons
  module AdvancedRescue
    def rescue_with_logging(returned_value, options={log_errors: true})
      begin
        yield
      rescue
        log_error_with_attributes(rescued_error_message(returned_value)) if options[:log_errors]
        returned_value
      end
    end

    protected

    def rescued_error_message(value)
      "#{self.class}##{caller_method} was rescued to #{value}"
    end

    def caller_method
      # get the method name from wherever rescue_with_logging was called
      caller_locations(4)[0].label
    end
  end
end
