require_relative 'boot'

require 'rails/all'
require "active_storage/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Crowdai
  LOCALES     = ['en'].freeze
  DATE_FORMAT = '%d %B %Y'.freeze

  class Application < Rails::Application
    config.load_defaults 5.2
    config.action_controller.default_protect_from_forgery = false

    config.assets.version = '2.0'

    config.exceptions_app           = routes
    config.active_job.queue_adapter = :sidekiq
    config.secret_key_base          = ENV["SECRET_KEY_BASE"]
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths                     += Dir["#{Rails.root}/app/models/**/"]
    config.autoload_paths                     += Dir["#{Rails.root}/app/queries/**/"]
    config.active_record.time_zone_aware_types = [:datetime]
    config.ssl_options                         = { hsts: { subdomains: false } }
    config.assets.precompile                  += ['application.scss']
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    Rails.env.development? && config.assets.paths << File.join(ENV['FOG_LOCAL_ROOT'], ENV['AWS_S3_BUCKET'])

    config.i18n.load_path        += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = LOCALES
    config.i18n.default_locale    = LOCALES[0]
    config.i18n.fallbacks         = LOCALES

    config.action_view.sanitized_allowed_tags =
      Set.new(['strong', 'em', 'b', 'i', 'p', 'code', 'pre', 'tt', 'samp', 'kbd', 'var', 'sub', 'sup', 'dfn', 'cite', 'big', 'small', 'address', 'hr', 'br', 'div', 'span', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'dl', 'dt', 'dd', 'abbr', 'acronym', 'a', 'img', 'blockquote', 'del', 'ins', 'table', 'tr', 'td'])

    config.generators do |g|
      g.test_framework :rspec
      g.stylesheets false
      g.helper false
      g.assets false
      g.view false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.to_prepare do
      Doorkeeper::ApplicationsController.layout "application"
      Doorkeeper::AuthorizationsController.layout "application"
      Doorkeeper::AuthorizedApplicationsController.layout "application"
    end

    # from https://stackoverflow.com/questions/49265645/rails-cloudfront-no-access-control-allow-origin-header-is-present
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins [ENV['DOMAIN_NAME']]
        resource '/assets/*', headers: :any, methods: [:get, :post, :options]
      end
    end

    console do
      ARGV.push "-r", root.join("lib/console.rb")
    end
  end
end
