require 'sidekiq/testing'

Rails.application.configure do
  figaro_file = File.join(Rails.root, 'config', 'application.yml')
  YAML.load_file(figaro_file).symbolize_keys[:test].each do |key, value|
    ENV[key.to_s] = value
  end
  config.cache_classes                              = false
  config.eager_load                                 = false
  config.consider_all_requests_local                = false
  config.action_controller.perform_caching          = false
  config.action_dispatch.show_exceptions            = true
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching              = false
  config.action_mailer.delivery_method              = :test
  config.active_support.deprecation                 = :stderr
  config.assets.raise_runtime_errors                = true
  config.assets.debug                               = false
  config.assets.check_precompiled_asset             = false
  config.assets.unknown_asset_fallback              = true
  config.logger                                     = Logger.new(nil)
  config.log_level                                  = :fatal
  config.active_record.logger                       = nil
  config.active_storage.service                     = :test
end

Rails.application.routes.default_url_options[:host] = ENV['DOMAIN_NAME']
