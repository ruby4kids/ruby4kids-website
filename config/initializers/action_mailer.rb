ActionMailer::Base.delivery_method = :smtp 

ActionMailer::Base.smtp_settings = { 
:address => "postman.opnet.com", 
:port => 25, 
:domain => "opnet.com" 
#:authentication => :login, 
#:user_name => "dave", 
#:password => "secret", 
}