class PasswordsController < ApplicationController
  skip_before_filter :require_login

  def new
  end

  def create
    @user = User.find_by_insensitive_email(params[:email])
    @user.deliver_reset_password_instructions! if @user

    redirect_to root_path, notice: "Password reset instructions have been sent to your email."
  end

  def edit
    @user = User.load_from_reset_password_token(params[:id])
    redirect_to new_password_path, alert: "Invalid or expired password reset token. Please request new password reset instructions." and return unless @user
  end
end
