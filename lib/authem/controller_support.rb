module Authem::ControllerSupport
  extend ActiveSupport::Concern

  protected

  def sign_in(user)
    session[:session_token] = user.session_token
  end

  def sign_out
    session[:session_token] = nil
    reset_session
    current_user.reset_session_token! if current_user
    @current_user = nil
  end

  def current_user
    @current_user ||= if session[:session_token]
      Authem::Config.user_class.where(session_token: session[:session_token].to_s).first
    end
  end

  def require_user
    unless signed_in?
      session[:return_to_url] = request.url unless request.xhr?
      redirect_to Authem::Config.sign_in_path
    end
  end

  def signed_in?
    current_user.present?
  end

  def redirect_back_or_to(url, flash_hash = {})
    url = session[:return_to_url] || url
    session[:return_to_url] = nil
    redirect_to(url, :flash => flash_hash)
  end

  included do
    helper_method :current_user
    helper_method :signed_in?
  end

end
