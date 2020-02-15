require 'rails_helper'

RSpec.describe Api::ClefTasksController, type: :request do
  let!(:organizer) { create :organizer, api_key: '3d1efc2332200314c86d2921dd33434c' }
  let!(:participant) { create :participant }
  let!(:participant2) { create :participant }
  let!(:clef_task) do
    create :clef_task, organizer: organizer
  end
  let!(:participant_clef_task) do
    create :participant_clef_task,
           clef_task:   clef_task,
           participant: participant
  end
  let!(:participant_clef_task2) do
    create :participant_clef_task,
           clef_task:   clef_task,
           participant: participant2,
           status_cd:   'submitted'
  end

  describe "validate user API key" do
    context "with organiser auth key" do
      before do
        get "/api/clef_tasks/#{clef_task.id}",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(organizer.api_key)
            }
      end

      it { expect(response).to have_http_status(:ok) }
    end

    context "with invalid organiser auth key" do
      before do
        get "/api/clef_tasks/#{clef_task.id}",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header('123435346464574576865')
            }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe "GET /api/clef_tasks" do
    context 'invalid clef_task_id' do
      before do
        get "/api/clef_tasks/99999",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(organizer.api_key)
            }
      end

      it { expect(response).to have_http_status(:not_found) }
    end

    context 'valid clef_task_id and no status argument' do
      before do
        get "/api/clef_tasks/#{clef_task.id}",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(organizer.api_key)
            }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["message"].length).to be(2) }
      it { expect(JSON.parse(response.body)["message"][0]["status_cd"]).to eq("requested") }
      it { expect(JSON.parse(response.body)["message"][1]["status_cd"]).to eq("submitted") }
      it { expect(JSON.parse(response.body)["message"][0]["participant"]['email']).to be_truthy }
    end

    context 'valid clef_task_id and valid status argument' do
      before do
        get "/api/clef_tasks/#{clef_task.id}?status=submitted",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(organizer.api_key)
            }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["message"].length).to be(1) }
      it { expect(JSON.parse(response.body)["message"][0]["status_cd"]).to eq("submitted") }
      it { expect(JSON.parse(response.body)["message"][0]["participant"]['email']).to be_truthy }
    end

    context 'valid clef_task_id and invalid status argument' do
      before do
        get "/api/clef_tasks/#{clef_task.id}?status=12345",
            headers: {
              'Content-Type':  'application/vnd.api+json',
              'Authorization': auth_header(organizer.api_key)
            }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)["message"]).to be_empty }
    end
  end
end
