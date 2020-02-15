require 'rails_helper'

describe "site navigation for admin" do
  let!(:participant) { create(:participant, :admin) }
  3.times do |i|
    let!("challenge_#{i + 1}") { create :challenge, :running }
  end
  let(:draft) { create :challenge, :draft }

  context "landing page" do
    it do
      log_in(participant)
      visit_landing_page
      expect(page).to have_content challenge_1.challenge
      expect(page).to have_link 'Knowledge Base'
      expect(page).to have_link 'Challenges'
      expect(page).to have_link 'Admin'
    end
  end

  context "challenges" do
    it do
      log_in(participant)
      visit_landing_page
      visit_challenges
      expect(page).to have_content challenge_1.challenge
      expect(page).to have_content challenge_2.challenge
      expect(page).to have_content challenge_3.challenge
      expect(page).not_to have_content draft.challenge
    end
  end

  context 'challenge page' do
    it do
      log_in(participant)
      visit_challenge(challenge_1)
      expect(page).to have_link 'Overview'
      expect(page).to have_link 'Leaderboard'
      expect(page).to have_link 'Discussion'
      expect(page).to have_link 'Dataset'
      expect(page).to have_link 'FOLLOW'
      # TODO - icons ... expect(page).not_to have_link 'Edit'
    end
  end

  context "challenge tabs", :js do
    it do
      log_in(participant)
      visit_challenge(challenge_1)
      click_link "Overview"
      expect(page).to have_link 'Overview', class: 'active'
      click_link "Leaderboard"
      expect(page).to have_link 'Leaderboard', class: 'active'
      click_link "Discussion"
      expect(page).to have_link 'Discussion', class: 'active'
      click_link "Dataset"
      expect(page).to have_link 'Dataset', class: 'active'
    end
  end

  context 'organizer' do
    it do
      log_in(participant)
      visit_challenge(challenge_1)
      click_link challenge_1.organizer.organizer
      expect(page).to have_text 'Members'
    end
  end
end
