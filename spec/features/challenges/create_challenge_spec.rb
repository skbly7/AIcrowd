require 'rails_helper'

describe "unauthorized" do
  let!(:organizer) { create :organizer }
  let(:participant) { create :participant }

  it 'not logged in' do
    visit new_challenge_path
    expect_sign_in
  end

  it 'user logged in' do
    log_in participant
    visit new_challenge_path
    expect_unauthorized
  end
end

describe 'An organizer creates a challenge' do
  let!(:organizer) { create :organizer }
  let!(:participant) { create :participant, organizer: organizer }
  let!(:challenge) { build :challenge }

  it 'create challenge', :js do
    log_in participant
    visit organizer_path(organizer, wait: 1)
    expect(page).to have_text organizer.organizer
    # expect(page).to have_selector '.btn', text: 'CREATE CHALLENGE'
  end
end
