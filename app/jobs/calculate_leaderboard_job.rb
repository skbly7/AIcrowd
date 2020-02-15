class CalculateLeaderboardJob < ApplicationJob
  queue_as :default

  def perform(challenge_round_id:)
    if ChallengeRound.find(challenge_round_id).challenge.challenge == "NeurIPS 2019 : Disentanglement Challenge"
      NewCalculateLeaderboardService.new(challenge_round_id: challenge_round_id).call
    else
      CalculateLeaderboardService.new(challenge_round_id: challenge_round_id).call
    end
  end
end
