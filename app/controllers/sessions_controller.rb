class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    return render 'new' if user.nil?

    if user.activated?
      handle_activated_user(user)
    else
      handle_inactivated_user
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def handle_inactivated_user
    message = 'Account not activated. Check your email for the activation link.'
    flash[:warning] = message
    redirect_to root_url
  end

  def handle_activated_user(user)
    log_in user
    params[:session][:remember_me] == '1' ? remember(user) : forget(user)
    redirect_back_or user
  end
end
