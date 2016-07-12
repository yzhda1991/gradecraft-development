require_relative "../presenters/exports/base"

class ExportsController < ApplicationController
  before_filter :ensure_staff?

  def index
    render :index, locals: { presenter: presenter }
  end

  protected

  def presenter
    @presenter ||= ::Presenters::Exports::Base.new \
      params: params,
      current_course: current_course,
      current_user: current_user
  end
end
