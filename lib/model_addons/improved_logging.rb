module ModelAddons
  module ImprovedLogging
    def log_with_attributes(type=:info, message)
      if valid_logging_types.include? type # a valid logging type is being used
        logger.send type, formatted_log_output(message)
      else
        logger.send :error, invalid_logging_type_message
      end
    end

    def log_error_with_attributes(message)
      log_with_attributes(:error, message)
    end

    def log_info_with_attributes(message)
      log_with_attributes(:info, message)
    end

    def log_warning_with_attributes(message)
      log_with_attributes(:warn, message)
    end

    protected
    def valid_logging_types
      [:debug, :info, :warn, :error, :fatal]
    end

    def formatted_log_output(message)
      "#{message.capitalize} in object #{self}.\n#{self} attributes: #{self.attributes}"
    end

    def invalid_logging_type_message
      formatted_log_output("Attempted to log with an incorrect type in ModelAddons::ImprovedLogging#log_with_attributes")
    end
  end
end
