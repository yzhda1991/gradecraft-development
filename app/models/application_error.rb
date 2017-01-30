class ApplicationError
  attr_accessor :message, :header, :status_code, :redirect_path

  def initialize(attributes={})
    @message = attributes[:message] || "It's so dark out! Something has gone wrong."
    @header = attributes[:header] || "Server Error"
    @status_code = attributes[:status_code] || 500
    @redirect_path = attributes[:redirect_path] || Rails.application.routes.url_helpers.root_path
  end
end
