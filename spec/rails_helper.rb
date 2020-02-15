ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

require 'spec_helper'
require 'rspec/rails'

require 'support/config/capybara'
require 'support/config/factory_bot'
require 'support/config/warden'
require 'support/config/vcr'

require 'pundit/matchers'

Dir[File.dirname(__FILE__) + "/support/helpers/*.rb"].each { |f| require f }
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include HeaderHelpers
  config.include FeatureSpecHelpers, type: :feature

  config.use_transactional_fixtures           = true
  config.example_status_persistence_file_path = 'spec/examples.txt'

  ActiveJob::Base.queue_adapter = :test
end
