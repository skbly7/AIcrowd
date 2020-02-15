# frozen_string_literal: true

module FeatureSpecHelpers
  def log_in(participant)
    visit new_participant_session_path
    fill_in 'Email address', with: participant.email
    fill_in 'Password', with: participant.password
    click_button 'Log In'
  end

  def expect_sign_in
    expect(page).to have_current_path new_participant_session_path, ignore_query: true
    expect(page).to have_text 'You need to sign in or sign up before continuing'
  end

  def expect_unauthorized
    expect(page).to have_current_path '/'
    expect(page).to have_text 'You are not authorised to access this page.'
  end

  def visit_landing_page
    visit '/'
  end

  def visit_challenges
    visit_landing_page
    within 'nav.primary' do
      click_link 'Challenges'
    end
  end

  def visit_challenge(challenge)
    visit_landing_page
    click_link challenge.challenge
  end

  def visit_knowledge_base
    visit_landing_page
    within 'nav.primary' do
      click_link 'Knowledge Base'
    end
  end

  def open_menu
    visit '/'
    find("#toggle-user").click
  end

  def visit_own_profile(participant)
    open_menu(participant)
    click_link 'Profile'
  end
end
