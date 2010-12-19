Ruby4Kids::Application.configure do
  config.cache_classes                          = false
  config.consider_all_requests_local            = true
  config.whiny_nils                             = true
  config.action_controller.perform_caching      = false
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.default_url_options      = { host: 'localhost:3000' }
  config.action_mailer.raise_delivery_errors    = false
  config.active_support.deprecation             = :log
  config.action_view.debug_rjs                  = true
end
