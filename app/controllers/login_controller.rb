class LoginController < ApplicationController
  
  layout 'login'
    
  def login
    session[:account_id] = nil
    if request.post?
      @current_account = Account.authenticate(params[:username], params[:password])
      if @current_account
        session[:account_id] = @current_account.id
        session[:person_id] = @current_account.person.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to (uri || {:controller => "welcome", :action => "index"})
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  
  def index
    redirect_to(:controller => "login", :action => "login")
  end
  
  def forgot_password
    if request.post?
      account = Account.find_by_email(params[:email])
      if(account)
        #email password to user
        email = Notification.deliver_forgot_password(account)
        Notification.deliver(email)
        flash[:notice] = "Your account information has been sent to you via email."
        redirect_to(:controller => "login", :action => "login")
      else
        #send error
        flash[:notice] = "The email you entered does not have an account in this system."
      end
    end
  end
  

  def logout
    session[:account_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:controller => "welcome", :action => "index")
  end
  
end
