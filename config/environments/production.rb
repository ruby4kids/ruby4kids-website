Ruby4Kids::Application.configure do
  config.cache_classes                     = true
  # config.cache_store                       = :mem_cache_store
  config.consider_all_requests_local       = false
  config.i18n.fallbacks                    = true
  config.serve_static_assets = false
  # config.action_controller.asset_host      = "http://assets.example.com"
  config.action_controller.perform_caching = true
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # nginx
  config.active_support.deprecation        = :notify
end
