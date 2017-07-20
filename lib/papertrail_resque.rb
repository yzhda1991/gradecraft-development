require "active_support"
require "remote_syslog_logger"

module PapertrailResque
  def logger
    @logger ||= ActiveSupport::TaggedLogging.new(
                  RemoteSyslogLogger.new(
                    "logs6.papertrailapp.com",
                    20258,
                    program: "jobs-#{ENV["RAILS_ENV"]}")
                )
  end
end
