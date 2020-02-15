require 'rails_helper'

describe ParticipantClefTasksController, type: :request do
  describe '#create' do
    let(:challenge)   { create(:challenge) }
    let(:participant) { create(:participant) }
    let(:clef_task) { create(:clef_task) }
    let(:params) do
      {
        participant_clef_task: {
          clef_task_id: clef_task.id,
          eua_file: 'test_pdf_file.pdf',
          challenge_id: challenge.id
        }
      }
    end

    context 'when user is not logged' do
      it 'redirects to login page' do
        post participant_clef_tasks_path, params: params

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to(new_participant_session_path)
      end
    end

    context 'when user is logged in as participant' do
      before { login_as(participant) }

      it 'creates new participant_clef_task record' do
        expect { post participant_clef_tasks_path, params: params }.to change{ParticipantClefTask.count}.by(1)

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to(clef_task_task_dataset_files_path(clef_task, challenge_id: challenge.id))
      end
    end
  end
end
