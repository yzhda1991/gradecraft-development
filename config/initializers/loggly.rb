# Rails 4 loggly add to broadcast
# loggly = Logglier.new("tcp://logs-01.loggly.com:514")

if Rails.env.production? || Rails.env.development?
  loggly = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/rails-#{Rails.env}", threaded: false, format: :json)
  Rails.logger.extend(ActiveSupport::Logger.broadcast(loggly))
end
