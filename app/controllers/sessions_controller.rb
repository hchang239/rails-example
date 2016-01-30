class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] ? remember(user) : forget(user)
      redirect_to user
    else
      # Note: render does not invoke request unlike redirect_to.
      #       flash.now disappear as soon as there is an additional request
      #       Thus, flash.now should be used with render so that the message(s)
      #       can be destroyed right after its first display
      flash.now[:danger] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
