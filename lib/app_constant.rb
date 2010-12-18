class AppConstant
  @@config = {
    "system_person_id" => 1,
    "max_per_page" => 200,
    "application" => 'ruby4kids',
    "server_http_address" => 'http://ruby4kids.opnet.com',
    "system_person_id" => 1,
  }
  cattr_accessor :config
end

PRODUCTION = (RAILS_ENV == 'production')

if !PRODUCTION
  # Constant Changes that are in common in both Dev and staging
  AppConstant.config["server_http_address"] = "http://ruby4kids.opnet.com"
end

