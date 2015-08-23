class PagesController < ApplicationController

  skip_before_filter :require_login

  def using_gradecraft
  end

  def auth_failure

  end

  def features

  end

  def contact

  end
end