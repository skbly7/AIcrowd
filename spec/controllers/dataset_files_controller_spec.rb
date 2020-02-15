require 'rails_helper'

describe DatasetFilesController, type: :controller do
  render_views

  let!(:challenge)             { create(:challenge, :running) }
  let!(:challenge_rules)       { create(:challenge_rules, challenge: challenge) }
  let!(:file1)                 { create(:dataset_file, challenge: challenge, title: 'file1') }
  let!(:file2)                 { create(:dataset_file, challenge: challenge, title: 'file2') }
  let!(:participant)           { create(:participant) }
  let!(:challenge_participant) { create(:challenge_participant, challenge: challenge, participant: participant) }

  context 'logged in as participant' do
    before { sign_in participant }

    describe 'GET #index' do
      before { Aws::S3::Object.any_instance.stub(:exists?).and_return(false) }

      it 'renders :index template' do
        get :index, params: { challenge_id: challenge.id }

        expect(response).to render_template :index
      end
    end

    describe "GET #new" do
      it "assigns a new dataset_file as @dataset_file" do
        get :new, params: { challenge_id: challenge.id }
        expect(assigns(:dataset_file)).to be_a_new(DatasetFile)
      end
    end
  end

  context 'logged in as admin' do
    let!(:admin)                 { create(:participant, :admin) }
    let!(:challenge_participant) { create(:challenge_participant, challenge: challenge, participant: admin) }

    before { sign_in admin }

    describe "DELETE #destroy" do
      def delete_file
        delete :destroy, params: { challenge_id: challenge.id, id: file1.id }
      end

      it 'removes dataset_file record from database' do
        Aws::S3::Client.any_instance.stub(:delete_object).and_return(true)

        expect { delete_file }.to change { DatasetFile.count }.by -1
        expect(response).to redirect_to(challenge_dataset_files_path(challenge))
        expect(flash[:notice]).to match "Dataset file #{file1.title} was deleted."
      end
    end
  end
end
