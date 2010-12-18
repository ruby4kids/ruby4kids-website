

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery :secret => '63b60690a83869510998949564c33188'
  
  before_filter :check_authentication, :check_rights, :except => [:login, :forgot_password]
  before_filter :set_current_person_id
  
  def current_account
    @current_account
  end
  
  def current_person
    @current_account.person
  end
  
  private
  
  def set_current_person_id
    Thread.current["person_id"] = session[:person_id] rescue nil
  end
  
  def check_authentication
    @current_account = Account.find(session[:account_id]) rescue nil
    unless @current_account
      session[:original_uri] = request.request_uri #remember where you came from, store that in the session
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login")
      return false
    end
  end
  
  def check_rights
    unless @current_account.has_right(self.class.to_s+'.'+action_name)
      request.env["HTTP_REFERER"] ? (flash[:notice] = "You are not authorized to view the page you requested"
      redirect_to :back) : (flash[:error] = "You are not authorized to view the page you requested"
      render :partial => '/shared/privilege_error')
      return false
    end
  end
  
end
