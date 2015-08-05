class PasswordsController < ApplicationController
  skip_before_filter :require_login

  def new
  end
end
