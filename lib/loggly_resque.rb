# when extending a class that is passed directly into Resque for the purposes of handling
# the Class#perform method, this will enable that class to log directly to Loggly if the #logger
# method is used to call the logger within the perform block

module LogglyResque
  def logger
    @logger ||= Logglier.new(logger_url, format: :json)
  end

  # these all need to be spec'd out
  # https://logs-01.loggly.com/inputs/<loggly-token>/tag/tag-name
  def logger_url
    [ logger_base_url, ENV['LOGGLY_TOKEN'], "tag", queue_tag_name ].join("/")
  end

  def logger_base_url
    "https://logs-01.loggly.com/inputs"
  end

  def queue_tag_name
    "#{@queue.to_s.gsub(/_+/,'-')}-jobs-#{Rails.env}"
  end
end
