require 'rails_helper'

describe "Accessing the OAuth provider page" do
  let!(:participant) { create :participant }
  let!(:admin) { create :participant, :admin }

  it 'public user' do
    visit "/oauth/applications"
    expect(page).to have_content 'Log in'
    expect(page).not_to have_content 'Your applications'
  end

  it 'participant user' do
    log_in(participant)
    visit "/oauth/applications"
    expect(page).to have_content 'You are already signed in'
    expect(page).not_to have_content 'Your applications'
  end

  it 'admin user' do
    log_in(admin)
    visit "/oauth/applications"
    expect(page).to have_content 'Your applications'
  end
end
