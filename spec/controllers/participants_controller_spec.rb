require 'rails_helper'


RSpec.describe ParticipantsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # ParticipantsController. As you add validations to ParticipantsController, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ParticipantsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all participants_controllers as @participants_controllers" do
      participants_controller = ParticipantsController.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:participants_controllers)).to eq([participants_controller])
    end
  end

  describe "GET #show" do
    it "assigns the requested participants_controller as @participants_controller" do
      participants_controller = ParticipantsController.create! valid_attributes
      get :show, params: {id: participants_controller.to_param}, session: valid_session
      expect(assigns(:participants_controller)).to eq(participants_controller)
    end
  end

  describe "GET #new" do
    it "assigns a new participants_controller as @participants_controller" do
      get :new, params: {}, session: valid_session
      expect(assigns(:participants_controller)).to be_a_new(ParticipantsController)
    end
  end

  describe "GET #edit" do
    it "assigns the requested participants_controller as @participants_controller" do
      participants_controller = ParticipantsController.create! valid_attributes
      get :edit, params: {id: participants_controller.to_param}, session: valid_session
      expect(assigns(:participants_controller)).to eq(participants_controller)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new ParticipantsController" do
        expect {
          post :create, params: {participants_controller: valid_attributes}, session: valid_session
        }.to change(ParticipantsController, :count).by(1)
      end

      it "assigns a newly created participants_controller as @participants_controller" do
        post :create, params: {participants_controller: valid_attributes}, session: valid_session
        expect(assigns(:participants_controller)).to be_a(ParticipantsController)
        expect(assigns(:participants_controller)).to be_persisted
      end

      it "redirects to the created participants_controller" do
        post :create, params: {participants_controller: valid_attributes}, session: valid_session
        expect(response).to redirect_to(ParticipantsController.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved participants_controller as @participants_controller" do
        post :create, params: {participants_controller: invalid_attributes}, session: valid_session
        expect(assigns(:participants_controller)).to be_a_new(ParticipantsController)
      end

      it "re-renders the 'new' template" do
        post :create, params: {participants_controller: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested participants_controller" do
        participants_controller = ParticipantsController.create! valid_attributes
        put :update, params: {id: participants_controller.to_param, participants_controller: new_attributes}, session: valid_session
        participants_controller.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested participants_controller as @participants_controller" do
        participants_controller = ParticipantsController.create! valid_attributes
        put :update, params: {id: participants_controller.to_param, participants_controller: valid_attributes}, session: valid_session
        expect(assigns(:participants_controller)).to eq(participants_controller)
      end

      it "redirects to the participants_controller" do
        participants_controller = ParticipantsController.create! valid_attributes
        put :update, params: {id: participants_controller.to_param, participants_controller: valid_attributes}, session: valid_session
        expect(response).to redirect_to(participants_controller)
      end
    end

    context "with invalid params" do
      it "assigns the participants_controller as @participants_controller" do
        participants_controller = ParticipantsController.create! valid_attributes
        put :update, params: {id: participants_controller.to_param, participants_controller: invalid_attributes}, session: valid_session
        expect(assigns(:participants_controller)).to eq(participants_controller)
      end

      it "re-renders the 'edit' template" do
        participants_controller = ParticipantsController.create! valid_attributes
        put :update, params: {id: participants_controller.to_param, participants_controller: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested participants_controller" do
      participants_controller = ParticipantsController.create! valid_attributes
      expect {
        delete :destroy, params: {id: participants_controller.to_param}, session: valid_session
      }.to change(ParticipantsController, :count).by(-1)
    end

    it "redirects to the participants_controllers list" do
      participants_controller = ParticipantsController.create! valid_attributes
      delete :destroy, params: {id: participants_controller.to_param}, session: valid_session
      expect(response).to redirect_to(participants_controllers_url)
    end
  end

end
