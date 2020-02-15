require 'rails_helper'

describe JobPostingsController, type: :controller do
  render_views

  let!(:job_postings) { create_list(:job_posting, 3) }

  describe "GET #index" do
    it "returns a success response" do
      get :index

      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: job_postings.first.id }

      expect(response).to render_template(:show)
    end
  end
end
