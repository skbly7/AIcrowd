class LandingPageController < ApplicationController
  before_action :terminate_challenge, only: [:index]

  def index
    @challenges = Challenge
                      .where(private_challenge: false)
                      .where(hidden_challenge: false)
                      .where.not(status_cd: :draft)
                      .limit(6)
    @partners = Partner
                    .where(visible: true)
                    .where.not(image_file: nil)
                    .order(seq: :asc)
                    .limit(8)
    @blog_posts = Blog
                      .where(published: true)
                      .order(seq: :asc)
                      .limit(4)
    @participants = Participant
                        .reorder(created_at: :desc)
                        .limit(5)
  end

  def host
    @page_title     = "Organize"
    @challenge_call = ChallengeCall.first
  end
end
