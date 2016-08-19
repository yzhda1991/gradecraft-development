require "active_lms"

ActiveLMS.configure do |config|
  config.provider :canvas do |canvas|
    canvas.client_id = ENV["CANVAS_CLIENT_ID"]
    canvas.client_secret = ENV["CANVAS_CLIENT_SECRET"]
    canvas.client_options = {
      site: "#{ENV["CANVAS_BASE_URL"]}/login/canvas"
    }
  end
end
