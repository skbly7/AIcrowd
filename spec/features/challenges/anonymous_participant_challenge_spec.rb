require 'rails_helper'

describe "challenge", :js do
  let!(:challenge) { create(:challenge, :running) }
  let!(:draft_challenge) { create(:challenge, :draft) }
  let!(:participant) { create(:participant) }

  describe "anonymous participant can view challenges list" do
    before do
      visit '/'
    end

    specify { expect(page).to have_link challenge.challenge }
    specify { expect(page).to have_selector(:link_or_button, 'Log in') }
    specify { expect(page).to have_link 'Blog' }
    specify { expect(page).to have_link 'Challenges' }
  end

  describe "anonymous participant can view some challenges details" do
    before do
      visit '/challenges'
      click_link challenge.challenge
    end

    specify { expect(page).to have_link 'Log in' }
    specify { expect(page).to have_content challenge.challenge }
    specify { expect(page).to have_content challenge.tagline }
  end

  describe "anonymous participant" do
    before do
      visit '/challenges'
      click_link challenge.challenge
    end

    it "can follow Overview link" do
      click_link "Overview"
      expect(page).to have_content 'Overview'
    end

    it "can follow Leaderboard link" do
      click_link "Leaderboard"
      expect(page).to have_content 'Leaderboard'
    end

    it "cannot follow Resources link" do
      click_link "Resources"
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end

  describe "participant is required to log in to access restricted parts of the challenge" do
    before do
      visit '/challenges'
      click_link challenge.challenge
    end

    it "follow Resources link" do
      click_link "Resources"
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end

  describe "anonymous participant cannot access restricted pages via url manipulation" do
    before { visit root_path }

    it "show for draft challenge" do
      visit "/challenges/#{draft_challenge.id}"
      expect(page).to have_current_path('/participants/sign_in')
    end

    it "show for running challenge" do
      visit "/challenges/#{challenge.slug}"
      expect(page).to have_current_path("/challenges/#{challenge.slug}", ignore_query: true)
    end

    it "edit challenge" do
      visit "/challenges/#{draft_challenge.id}/edit"
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end

    it "new challenge" do
      visit "/challenges/new"
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end
end
