require 'rails_helper'

describe TaskDatasetFileDownloadsController, type: :controller do
  let!(:task_dataset_file) { create(:task_dataset_file) }
  let(:participant)        { create(:participant) }

  describe 'POST #create' do
    before { sign_in participant }

    context 'with valid params' do
      it 'creates a new TaskDatasetFileDownload' do
        expect {
          post :create, params: { task_dataset_file_id: task_dataset_file.id }
        }.to change(TaskDatasetFileDownload, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      it 'raises ActiveRecord::RecordNotFound error' do
        expect {
          post :create, params: { task_dataset_file_id: 0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
