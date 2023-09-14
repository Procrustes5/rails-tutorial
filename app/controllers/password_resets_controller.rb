class PasswordResetsController < ApplicationController
  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      # ここのコードの繰り返しを無くしたい
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    end
  end

  def edit; end
end
