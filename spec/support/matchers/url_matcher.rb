# frozen_string_literal: true

RSpec::Matchers.define :be_a_valid_url do |expected|
  match do |actual|
    URI.parse(actual)
  rescue StandardError
    false
  end
end
# TODO probably a better way of doing this
