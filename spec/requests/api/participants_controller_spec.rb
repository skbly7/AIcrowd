require 'rails_helper'

RSpec.describe Api::ParticipantsController, type: :request do
  let!(:organizer) do
    create :organizer,
           api_key: '3d1efc2332200314c86d2921dd33434c'
  end
  let!(:participant) do
    create :participant,
           api_key: 'a1f61dbec17954ac6befcdb1c9cc6bb8'
  end

  describe 'with valid admin API key' do
    before do
      get "/api/participants/#{participant.name}",
          headers: {
            'Accept':        'application/vnd.api+json',
            'Content-Type':  'application/vnd.api+json',
            'Authorization': auth_header(ENV['CROWDAI_API_KEY'])
          }
    end

    it { expect(response).to have_http_status(:ok) }

    it {
      expect(JSON.parse(response.body)["api_key"])
      .to eq(participant.api_key)
    }
  end

  describe 'with organizer API key (invalid)' do
    before do
      get "/api/participants/#{participant.name}",
          headers: {
            'Accept':        'application/vnd.api+json',
            'Content-Type':  'application/vnd.api+json',
            'Authorization': auth_header(organizer.api_key)
          }
    end

    it { expect(response).to have_http_status(:unauthorized) }
  end
end
