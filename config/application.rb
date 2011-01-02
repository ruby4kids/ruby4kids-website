require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'yaml'
APP_CONFIG = YAML.load_file(File.expand_path('../application.yml', __FILE__))

module Ruby4Kids
  class Application < Rails::Application

    config.encoding           = "utf-8"
    config.filter_parameters += [:password]

    config.generators do |g|
      g.template_engine :erb
      g.test_framework  :rspec, :fixture => false
    end

  end
end
