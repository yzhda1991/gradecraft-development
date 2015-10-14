# set a base path for http loggly calls
http_base_path = "https://logs-01.loggly.com/inputs/"

# build a new background job logger
background_job_logger = Logglier.new("#{http_base_path}/#{ENV['LOGGLY_TOKEN']}/tag/background-jobs-#{Rails.env}", threaded: true, format: :json)

# set the background job logger as a Rails configuration
Rails.application.config.loggers.background_job = background_job_logger
