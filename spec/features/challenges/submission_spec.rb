require "rails_helper"

describe 'submissions not allowed' do
  let!(:participation_terms) do
    create :participation_terms
  end
  let!(:running) { create :challenge, :running, online_submissions: true }
  let!(:draft) { create :challenge }
  let!(:draft_rules) do
    create :challenge_rules,
           challenge: draft
  end
  let!(:starting_soon) do
    create :challenge, :starting_soon
  end
  let!(:starting_soon_challenge_rules) do
    create :challenge_rules,
           challenge: starting_soon
  end
  let!(:completed_closed) do
    create :challenge,
           :completed,
           online_submissions:         true,
           post_challenge_submissions: false
  end
  let!(:completed_closed_challenge_rules) do
    create :challenge_rules,
           challenge: completed_closed
  end
  let(:participant) { create :participant }
  let!(:starting_soon_participant) do
    create :challenge_participant,
           challenge:   starting_soon,
           participant: participant
  end
  let!(:completed_closed_participant) do
    create :challenge_participant,
           challenge:   completed_closed,
           participant: participant
  end
  let!(:draft_participant) do
    create :challenge_participant,
           challenge:   draft,
           participant: participant
  end

  it 'public user' do
    visit new_challenge_submission_path(running)
    expect_sign_in
    visit new_challenge_submission_path(draft)
    expect_sign_in
    visit new_challenge_submission_path(starting_soon)
    expect_sign_in
    visit new_challenge_submission_path(completed_closed)
    expect_sign_in
  end

  it 'participant' do
    log_in participant
    visit new_challenge_submission_path(draft)
    expect_unauthorized
    visit new_challenge_submission_path(starting_soon)
    expect_unauthorized
    visit new_challenge_submission_path(completed_closed)
    expect_unauthorized
  end
end

describe 'challenge running' do
  let!(:participation_terms) do
    create :participation_terms
  end
  let!(:running) { create :challenge, :running, online_submissions: true }
  let!(:running_rules) do
    create :challenge_rules,
           challenge: running
  end
  let(:participant) { create :participant }
  let!(:running_participant) do
    create :challenge_participant,
           challenge:   running,
           participant: participant
  end

  it do
    log_in participant
    visit new_challenge_submission_path(running)
    expect(page).to have_text 'Create Submission'
  end
end

describe 'challenge ended' do
  let!(:participation_terms) do
    create :participation_terms
  end
  let!(:challenge) do
    create :challenge,
           :completed,
           online_submissions:         true,
           post_challenge_submissions: true
  end
  let!(:challenge_rules) do
    create :challenge_rules,
           challenge: challenge
  end
  let(:participant) { create :participant }
  let!(:challenge_participant) do
    create :challenge_participant,
           challenge:   challenge,
           participant: participant
  end

  it do
    log_in participant
    visit new_challenge_submission_path(challenge)
    expect(page).to have_text 'Create Submission'
    expect(page).to have_text 'This challenge is now completed. You may continue to make submissions and your entries will appear on the Ongoing Leaderboard.'
  end

  it do
    challenge.update(post_challenge_submissions: false)
    log_in participant
    visit new_challenge_submission_path(challenge)
    expect_unauthorized
  end
end
