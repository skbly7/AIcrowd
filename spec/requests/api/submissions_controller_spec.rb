require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :request do
  let!(:organizer) do
    create :organizer,
           api_key: '3d1efc2332200314c86d2921dd33434c'
  end
  let!(:clef_task) do
    create :clef_task,
           organizer: organizer
  end
  let!(:challenge) do
    create :challenge,
           :running,
           organizer: organizer
  end

  5.times do |i|
    let!("submission_#{i + 1}") do
      create :submission,
             challenge:  challenge,
             created_at: (6 - i).days.ago
    end
  end

  # describe 'with valid API key' do
  #   context "with organiser auth key" do
  #     before do
  #       get "/api/challenges/#{challenge.id}/submissions",
  #         headers: {
  #           'Accept': 'application/vnd.api+json',
  #           'Content-Type': 'application/vnd.api+json',
  #           'Authorization': auth_header(organizer.api_key) }
  #     end
  #     it { expect(response).to have_http_status(200) }
  #   end
  # end

  describe 'GET #show' do
    context "with admin auth key" do
      before do
        get "/api/submissions/#{submission_1.id}",
            headers: {
              'Accept':        'application/vnd.api+json',
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(ENV['CROWDAI_API_KEY'])
            }
      end

      it { expect(response).to have_http_status(:ok) }
    end
  end
end
