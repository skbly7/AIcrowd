require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = false
  config.cassette_library_dir                    = 'spec/vcr'
  config.ignore_localhost                        = true
  config.default_cassette_options                = { record: :new_episodes }

  config.configure_rspec_metadata!
  config.hook_into(:webmock)
end
