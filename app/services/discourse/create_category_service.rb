module Discourse
  class CreateCategoryService < ::Discourse::BaseService
    def initialize(challenge:)
      @client      = prepare_api_client
      @challenge   = challenge
    end

    def call
      retry_count ||= 0

      return failure('DiscourseApi client couldn\'t be properly initialized.') if client.nil?

      response = create_category_request(ensure_uniqueness: retry_count.positive?)
      challenge.update!(discourse_category_id: response['id'])

      success
    rescue DiscourseApi::UnprocessableEntity => e
      raise e if retry_count.positive?

      retry_count += 1

      retry if e.message.include?('Category Name has already been taken')
      retry if e.message.include?('Slug is already in use')
    rescue DiscourseApi::Error => e
      Logger.new(::Discourse::BaseService::LOGGER_URL).error("##{challenge.id} - Unable to create category - #{e.message}")

      failure('Discourse API is unavailable')
    end

    private

    attr_reader :client, :challenge

    def create_category_request(ensure_uniqueness: false)
      # Discouse API has following validations that we need to comply with:
      # - category name cannot be longer then 50 signs
      # - category name has to be unique
      # - slug has to be unique
      client.create_category(
        name:       truncated_string(challenge.challenge, ensure_uniqueness),
        slug:       truncated_string(challenge.slug, ensure_uniqueness),
        color:      ::Discourse::BaseService::CATEGORY_DEFAULT_COLOR,
        text_color: ::Discourse::BaseService::CATEGORY_DEFAULT_TEXT_COLOR
      )
    end
  end
end
