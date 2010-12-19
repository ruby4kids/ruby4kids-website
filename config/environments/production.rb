Ruby4Kids::Application.configure do
  config.cache_classes                     = true
  config.consider_all_requests_local       = false
  config.i18n.fallbacks                    = true
  config.serve_static_assets               = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.action_mailer.default_url_options = { host: 'ruby4kids.com' }
  config.active_support.deprecation        = :notify
end
