require 'simplecov'
SimpleCov.start 'rails' do
  coverage_dir 'coverage/spec'

  add_filter '/bin/'
  add_filter '/config/'
  add_filter '/features/'
  add_filter '/lib/'
  add_filter '/plugins/'
  add_filter '/scripts/'
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers',     'app/helpers'
  add_group 'Mailers',     'app/mailers'
  add_group 'Models',      'app/models'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'shoulda'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require 'factory_girl'
require 'faker'
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

require 'thinking_sphinx/test'
ThinkingSphinx::Test.init

def in_editor?
  ENV.has_key?('EMACS') || ENV.has_key?('TM_MODE') || ENV.has_key?('VIM')
end

def formatter
  ENV['WATCHR'] ? :documentation : :progress
end

RSpec.configure do |config|
  config.color_enabled              = !in_editor?
  config.formatter                  = formatter
  config.use_transactional_fixtures = true

  config.mock_with :rspec

  config.include Devise::TestHelpers, type: :controller

  config.before(:each) do
    Rails.logger.info "\n\nRunning \"#{example.full_description}\" (#{example.metadata[:location]})\n\n"
  end
end
