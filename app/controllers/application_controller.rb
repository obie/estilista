class ApplicationController < ActionController::Base

  helper_method :current_user, :editable?

  protected

  def current_user
    session[:current_user]
  end

  def editable?(post)
    current_user && (current_user == post.author || current_user.admin?)
  end

  def require_admin
    redirect_to root_path unless current_user && current_user.admin?
  end

  def require_user
    redirect_to root_path unless current_user
  end
end
