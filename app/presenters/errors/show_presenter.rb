class Errors::ShowPresenter < Showtime::Presenter
  attr_accessor :message, :header, :redirect_path

  def initialize(attributes={})
    @message = attributes[:message] || "It's so dark out! Something has gone wrong."
    @header = attributes[:header] || "Server Error"
    @redirect_path = attributes[:redirect_path] || Rails.application.routes.url_helpers.root_path
  end
end
