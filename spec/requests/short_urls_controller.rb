require 'rails_helper'

RSpec.describe "ShortUrlController", type: :request do
  let!(:submission) { create :submission }

  describe "valid short url" do
    it "redirects to leaderboard" do
      get "/#{submission.short_url}"
      expect(response).to have_http_status(:found)
    end
  end

  describe "invalid short url" do
    it "renders 404" do
      expect do
        get "/www123455"
      end.to raise_error ActionController::RoutingError
    end
  end
end
