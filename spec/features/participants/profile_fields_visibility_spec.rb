require "rails_helper"

describe 'API key visibility' do
  let(:participant) { create :participant }
  let(:admin) { create :participant, :admin }

  it "API key visible on participant's own profile" do
    log_in(participant)
    visit participant_path(participant.slug)
    expect(participant.api_key).not_to be_nil
    expect(page).to have_content participant.api_key
  end

  it "API key visible to admin users" do
    log_in(admin)
    visit participant_path(participant.slug)
    expect(participant.api_key).not_to be_nil
    expect(page).to have_content participant.api_key
  end

  it "API key not visible to public users" do
    visit participant_path(participant.slug)
    expect(participant.api_key).not_to be_nil
    expect(page).not_to have_content participant.api_key
  end
end

describe 'Email field visibility', :js do
  let(:participant) { create :participant }
  let(:admin) { create :participant, :admin }

  # scenario "Email address is not visible on participant's own profile" do
  #   log_in(participant)
  #   visit participant_path(participant.slug)
  #   expect(participant.email).not_to be_nil
  #   expect(page).not_to have_content participant.email
  # end

  # scenario "Email key visible to admin users" do
  #   log_in(admin)
  #   visit participant_path(participant.slug)
  #   expect(page).to have_content participant.email
  # end

  it "API key not visible to public users" do
    visit participant_path(participant.slug)
    expect(participant.api_key).not_to be_nil
    expect(page).not_to have_content participant.email
  end

  it "draft challenges not visible to public users" do
    # TODO
  end
end
