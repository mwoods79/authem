module Authem::ControllerSupport
  extend ActiveSupport::Concern

  protected

  def sign_in(user)
    session[:session_token] = user.sessions.create!.token
  end

  def sign_out
    Authem::Session.authenticate(session[:session_token]).try(:revoke!) if session[:session_token]
    session.delete(:session_token)
    @current_user = nil
  end

  def current_user
    @current_user ||= if session[:session_token]
      Authem::Session.authenticate(session[:session_token]).try(:authemable)
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
