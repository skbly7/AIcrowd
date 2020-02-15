module Discourse
  class BaseService < ::BaseService
    LOGGER_URL                  = 'log/discourse_api.log'.freeze
    CATEGORY_DEFAULT_COLOR      = '49d9e9'.freeze
    CATEGORY_DEFAULT_TEXT_COLOR = 'f0fcfd'.freeze

    protected

    def prepare_api_client
      return if ENV['DISCOURSE_DOMAIN_NAME'].blank?

      client              = DiscourseApi::Client.new(ENV['DISCOURSE_DOMAIN_NAME'])
      client.api_key      = ENV['DISCOURSE_API_KEY']
      client.api_username = ENV['DISCOURSE_API_USERNAME']

      client
    end

    def truncated_string(string, ensure_uniqueness)
      if ensure_uniqueness
        "#{string.to_s.truncate(43)}-#{SecureRandom.hex(3)}"
      else
        string.to_s.truncate(50)
      end
    end
  end
end
