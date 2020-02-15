require 'rails_helper'

describe OrganizerApplicationsController, type: :controller do
  render_views

  let(:valid_attributes) { FactoryBot.attributes_for(:organizer_application) }

  describe "POST #create" do
    it "creates a new OrganizerApplication" do
      expect {
        post :create, params: { organizer_application: valid_attributes }, format: :js
      }.to change(OrganizerApplication, :count).by(1)
    end

    it "queues Admin::OrganizerApplicationNotificationJob" do
      expect {
        post :create, params: { organizer_application: valid_attributes }, format: :js
      }.to have_enqueued_job(Admin::OrganizerApplicationNotificationJob)
    end

    it "queues OrganizerApplicationNotificationJob" do
      expect {
        post :create, params: { organizer_application: valid_attributes }, format: :js
      }.to have_enqueued_job(OrganizerApplicationNotificationJob)
    end
  end
end
