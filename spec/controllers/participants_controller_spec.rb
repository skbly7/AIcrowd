require 'rails_helper'

describe ParticipantsController, type: :controller do
  render_views

  let(:valid_attributes)   { FactoryBot.attributes_for(:participant) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:participant, :invalid) }

  context 'as a participant' do
    let(:participant) { create(:participant) }

    before { sign_in participant }

    describe "GET #show" do
      it "assigns the requested participant as @participant" do
        get :show, params: { id: participant.slug }

        expect(assigns(:participant)).to eq(participant)
      end
    end

    describe "GET #edit" do
      it "assigns the requested participant as @participant" do
        get :edit, params: { id: participant.slug }

        expect(assigns(:participant)).to eq(participant)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { { name: 'Sean' } }

        it "updates the requested participant" do
          put :update, params: { id: participant.slug, participant: new_attributes }

          expect(participant.reload.name).to eq(new_attributes[:name])
        end

        it "assigns the requested participant as @participant" do
          put :update, params: { id: participant.slug, participant: valid_attributes }

          expect(assigns(:participant)).to eq(participant)
        end
      end

      context "with invalid params" do
        it "assigns the participant as @participant" do
          put :update, params: { id: participant.slug, participant: invalid_attributes }

          expect(assigns(:participant)).to eq(participant)
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: participant.slug, participant: invalid_attributes }

          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested participant" do
        expect do
          delete :destroy, params: { id: participant.slug }
        end.to change(Participant, :count).by(-1)
      end

      it "redirects to the root" do
        delete :destroy, params: { id: participant.slug }
        expect(response).to redirect_to('/')
      end
    end
  end
end
