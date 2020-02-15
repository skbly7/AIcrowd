module Discourse
  class UpdateCategoryService < ::Discourse::BaseService
    def initialize(challenge:)
      @client    = prepare_api_client
      @challenge = challenge
    end

    def call
      retry_count ||= 0

      return failure('DiscourseApi client couldn\'t be properly initialized.') if client.nil?
      return failure('Discourse category doesn\'t exist in our database.') if challenge.discourse_category_id.blank?

      update_category_request(ensure_uniqueness: retry_count.positive?)

      success
    rescue DiscourseApi::UnprocessableEntity => e
      raise e if retry_count.positive?

      retry_count += 1

      retry if e.message.include?('Category Name has already been taken')
      retry if e.message.include?('Slug is already in use')
    rescue DiscourseApi::Error => e
      Logger.new(::Discourse::BaseService::LOGGER_URL).error("##{challenge.id} - Unable to update category - #{e.message}")

      failure('Discourse API is unavailable')
    end

    private

    attr_reader :client, :challenge

    def update_category_request(ensure_uniqueness: false)
      # Discouse API has following validations that we need to comply with:
      # - category name cannot be longer then 50 signs
      # - category name has to be unique
      # - slug has to be unique
      client.update_category(
        id:         challenge.discourse_category_id,
        name:       truncated_string(challenge.challenge, ensure_uniqueness),
        slug:       truncated_string(challenge.slug, ensure_uniqueness),
        color:      ::Discourse::BaseService::CATEGORY_DEFAULT_COLOR,
        text_color: ::Discourse::BaseService::CATEGORY_DEFAULT_TEXT_COLOR
      )
    end
  end
end
