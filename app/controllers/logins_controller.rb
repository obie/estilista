class LoginsController < ApplicationController
  def new
    redirect_to root_path and return if current_user
    if request.post?
      if valid_email?
        auth = Authentication.create(email: login_params[:email])
        LoginMailer.send_magic_link(auth).deliver_later
        render 'confirm'
      else
        flash[:error] = "Please supply a valid email address."
      end
    end
  end

  def create
    if !params[:token].blank? && authentication = Authentication.find(params[:token])
      session[:current_user] = authentication.user
      redirect_to root_path
    else
      session[:current_user] = nil if current_user
      render 'error'
    end
  end

  def destroy
    session[:current_user] = nil
    redirect_to root_path
  end

  private

  def login_params
    params.require(:login).permit(:email)
  end

  def valid_email?
    login_params[:email] =~ /[^\s]@[^\s]/
  end

end
