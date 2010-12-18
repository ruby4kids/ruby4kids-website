class Notification < ActionMailer::Base

  
  def forgot_password(account)
    @subject = "Request reset of password for your account"
    @body[:account] = account
    @body[:url] = AppConstant[]
    @recipients = account.email
    @from = "admin@ruby4kids.com"
    @headers = {}
    content_type 'text/html'
  end
  
end