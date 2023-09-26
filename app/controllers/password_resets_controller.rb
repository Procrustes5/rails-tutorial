class PasswordResetsController < ApplicationController
  before_action :set_user,         only: %i[edit update]
  before_action :valid_user,       except: %i[new create]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    flash[:info] = 'Email sent with password reset instructions'
    redirect_to root_url
  end

  def edit; end

  def update
    if @user.update(user_params)
      log_in @user
      @user.update(reset_digest: nil)
    end
    update_message_and_path
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end

  def update_message_and_path
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update(user_params)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      flash.now[:error] = 'There is some problem, Please try again'
      render 'edit'
    end
  end
end
