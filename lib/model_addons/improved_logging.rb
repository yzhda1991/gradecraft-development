module ModelAddons
  module ImprovedLogging
    def log_error_with_attributes(type=:info, message)
      Rails.logger.send type, final_output(message)
    end

    def log_error_with_attributes(message)
      log_with_attributes(:error, message)
    end

    protected
    def final_log_output(message)
      <<-output
        #{message} in #{self}.
        #{self} attributes: #{self.attributes}
      output
    end
  end
end
