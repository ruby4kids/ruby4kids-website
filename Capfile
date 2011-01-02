load 'deploy' if respond_to?(:namespace)
load 'config/deploy'
recipes_path = File.expand_path('../lib/deploy', __FILE__)
Dir[recipes_path + '/**/*.rb'].each { |recipe| load(recipe) }
