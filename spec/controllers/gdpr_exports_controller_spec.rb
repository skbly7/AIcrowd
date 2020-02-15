require 'rails_helper'

describe GdprExportsController, type: :controller do
  render_views

  let(:participant) { create(:participant) }

  context 'unauthenticated' do
    it "asks to sign in" do
      expect { post :create, xhr: true }.not_to have_enqueued_job(GdprExportJob)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'authenticated' do
    before { sign_in participant }

    it "queues the job" do
      expect { post :create, xhr: true }.to have_enqueued_job(GdprExportJob)

      expect(response).to have_http_status(:success)
    end
  end
end
