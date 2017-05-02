require "rails_helper"

RSpec.describe SubmissionFilesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/submission_files_controllers").to route_to("submission_files_controllers#index")
    end

    it "routes to #new" do
      expect(:get => "/submission_files_controllers/new").to route_to("submission_files_controllers#new")
    end

    it "routes to #show" do
      expect(:get => "/submission_files_controllers/1").to route_to("submission_files_controllers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/submission_files_controllers/1/edit").to route_to("submission_files_controllers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/submission_files_controllers").to route_to("submission_files_controllers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/submission_files_controllers/1").to route_to("submission_files_controllers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/submission_files_controllers/1").to route_to("submission_files_controllers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/submission_files_controllers/1").to route_to("submission_files_controllers#destroy", :id => "1")
    end

  end
end
