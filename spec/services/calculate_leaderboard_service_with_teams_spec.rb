require 'rails_helper'

describe CalculateLeaderboardService do
  # challenge
  let(:challenge1) { create :challenge, :running }
  let(:challenge2) { create :challenge, :running }

  let(:challenge1_round) do
    challenge1.challenge_rounds.first.tap do |challenge_round|
      challenge_round.update(primary_sort_order: :descending)
    end
  end

  let(:challenge2_round) do
    challenge2.challenge_rounds.first.tap do |challenge_round|
      challenge_round.update(primary_sort_order: :descending)
    end
  end

  # participants
  let!(:p1) { create :participant }
  let!(:p2) { create :participant }
  let!(:p3) { create :participant }
  let!(:p4) { create :participant }
  # teams
  let!(:team1) { create :team, challenge: challenge1, participants: [p1, p2] }
  let!(:team2) { create :team, challenge: challenge2, participants: [p1, p2] }
  let!(:team3) { create :team, challenge: challenge1, participants: [p3] }
  # submissions
  let!(:p1s2) do
    create(:submission,
           participant:        p1,
           challenge:          challenge2,
           challenge_round_id: challenge2_round.id,
           grading_status:     :graded,
           score:              30,
           created_at:         50.hours.ago
          )
  end
  let!(:p1s1) do
    create(:submission,
           participant:        p1,
           challenge:          challenge1,
           challenge_round_id: challenge1_round.id,
           grading_status:     :graded,
           score:              30,
           created_at:         50.hours.ago
          )
  end
  let!(:p2s1) do
    create(:submission,
           participant:        p2,
           challenge:          challenge1,
           challenge_round_id: challenge1_round.id,
           grading_status:     :graded,
           score:              40,
           created_at:         50.hours.ago
          )
  end
  let!(:p3s1) do
    create(:submission,
           participant:        p3,
           challenge:          challenge1,
           challenge_round_id: challenge1_round.id,
           grading_status:     :graded,
           score:              20,
           created_at:         50.hours.ago
          )
  end
  let!(:p3s2) do
    create(:submission,
           participant:        p3,
           challenge:          challenge2,
           challenge_round_id: challenge2_round.id,
           grading_status:     :graded,
           score:              20,
           created_at:         50.hours.ago
          )
  end
  let!(:p4s1) do
    create(:submission,
           participant:        p4,
           challenge:          challenge1,
           challenge_round_id: challenge1_round.id,
           grading_status:     :graded,
           score:              10,
           created_at:         50.hours.ago
          )
  end
  let!(:p4s2) do
    create(:submission,
           participant:        p4,
           challenge:          challenge1,
           challenge_round_id: challenge1_round.id,
           grading_status:     :graded,
           score:              5,
           created_at:         10.hours.ago
          )
  end

  # Leaderboard
  # Row | Submission | Submitter    | Score | Entries
  # ----|------------|--------------|-------|--------
  #  1  |  p2s1      |  team1       |  40   |  2
  #  2  |  p3s1      |  team3       |  20   |  1
  #  3  |  p4s1      |  p4_solo     |  10   |  2

  describe 'supports teams' do
    before do
      described_class.new(challenge_round_id: challenge1_round.id).call
      described_class.new(challenge_round_id: challenge2_round.id).call
    end

    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).count).to eq(2) }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).first.entries).to eq(1) }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).first.score).to eq(30) }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).first.participant).not_to be }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).first.submitter).to eq(team2) }

    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).second.entries).to eq(1) }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).second.score).to eq(20) }
    it { expect(Leaderboard.where(challenge_round_id: challenge2_round.id).second.submitter).to eq(p3) }

    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).count).to eq(3) }

    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).first.entries).to eq(2) }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).first.score).to eq(40) }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).first.participant).not_to be }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).first.submitter).to eq(team1) }

    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).second.participant).not_to be }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).second.submitter).to eq(team3) }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).second.score).to eq(20) }

    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).third.score).to eq(10) }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).third.submitter).to eq(p4) }
    it { expect(Leaderboard.where(challenge_round_id: challenge1_round.id).third.entries).to eq(2) }
  end
end
