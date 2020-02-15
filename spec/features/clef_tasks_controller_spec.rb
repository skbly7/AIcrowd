require 'rails_helper'

describe ClefTasksController, feature: true do
  describe '#show' do
    let!(:organizer)         { create(:organizer) }
    let!(:task_dataset_file) { create(:task_dataset_file, title: 'Task DataSet File Title') }
    let!(:clef_task)         { create(:clef_task, organizer: organizer, task_dataset_files: [task_dataset_file], task: 'Clef Task Name') }

    before { Aws::S3::Object.any_instance.stub(:exists?).and_return(false) }

    context 'when user is not logged in' do
      it 'redirects to login page' do
        visit organizer_clef_task_path(organizer, clef_task)

        expect(page).to have_http_status 200
        expect(page).to have_current_path new_participant_session_path
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when user is logged in' do
      let(:admin) { create(:participant, :admin) }

      before { log_in admin }

      it 'show clef_task page' do
        visit organizer_clef_task_path(organizer, clef_task)

        expect(page).to have_http_status 200
        expect(page).to have_current_path organizer_clef_task_path(organizer, clef_task)
        expect(page).to have_content('Clef Task Name')
      end
    end
  end
end
