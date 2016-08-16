rackup "config.ru"
port ENV["PUMA_PORT"] || 5000

pidfile ENV["PUMA_PID_FILE"] if ENV["PUMA_PID_FILE"]


state_path ENV["PUMA_STATE_FILE"] if ENV["PUMA_STATE_FILE"]

stdout_redirect ENV["PUMA_ERROR_LOG_FILE"] || 'log/puma.error.log', ENV["PUMA_ACCESS_LOG_FILE"] || 'log/puma.access.log', true
threads ENV["PUMA_THREAS_MIN"] || 0,ENV["PUMA_THREAS_MIN"] || 16
bind ENV["PUMA_BIND"] if ENV["PUMA_BIND"]
workers ENV["PUMA_WORKERS"] || 0
preload_app!
