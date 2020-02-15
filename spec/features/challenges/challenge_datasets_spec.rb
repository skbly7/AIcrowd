require 'rails_helper'

describe 'download dataset links' do
  let!(:challenge)                       { create :challenge, :running }
  let!(:challenge_rules)                 { create :challenge_rules, challenge: challenge }
  let!(:participation_terms)             { create :participation_terms }
  let!(:participant)                     { create :participant }
  let!(:challenge_participant)           { create :challenge_participant, challenge: challenge, participant: participant }
  let!(:admin)                           { create :participant, :admin }
  let!(:challenge_admin_participant)     { create :challenge_participant, challenge: challenge, participant: admin }
  let!(:organizer)                       { create :participant, organizer: challenge.organizer }
  let!(:challenge_organizer_participant) { create :challenge_participant, challenge: challenge, participant: organizer }

  before { Aws::S3::Object.any_instance.stub(:exists?).and_return(false) }

  context 'when logged in as participant' do
    it 'does not render Delete link' do
      log_in(participant)
      visit challenge_dataset_files_path(challenge)

      expect(page).not_to have_link 'Delete'
    end
  end

  context 'when logged in as admin' do
    it 'renders Delete link' do
      log_in(admin)
      visit challenge_dataset_files_path(challenge)

      expect(page).to have_link 'Delete'
    end
  end

  context 'when logged in as organizer' do
    it 'renders delete link' do
      log_in(organizer)
      visit challenge_dataset_files_path(challenge)

      expect(page).to have_link 'Delete'
    end
  end
end
