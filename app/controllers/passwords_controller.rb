class PasswordsController < ApplicationController
  skip_before_filter :require_login

  def new
  end

  def create
    @user = User.find_by_insensitive_email(params[:email])
    @user.deliver_reset_password_instructions! if @user

    redirect_to login_path, notice: "Password reset instructions have been sent to your email."
  end
end
