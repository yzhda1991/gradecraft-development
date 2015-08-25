class PagesController < ApplicationController

  skip_before_filter :require_login

  def auth_failure

  end

  def features

  end

  def contact

  end
end