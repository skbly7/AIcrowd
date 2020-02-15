require 'rails_helper'

describe CalculateLeaderboardService do
  subject { described_class.new(challenge_round_id: challenge_round.id) }

  let(:challenge)       { create(:challenge, :running) }
  let(:challenge_round) { challenge.challenge_rounds.first }

  describe '#order_by' do
    context 'when use_display option is true' do
      let(:result) { subject.order_by(use_display: true) }

      context 'when challenge_round sort orders are descending / descending' do
        before { challenge_round.update!(primary_sort_order: :descending, secondary_sort_order: :descending) }

        it 'orders by score_display descending and score_secondary_display descending' do
          expect(result).to eq('score_display desc NULLS LAST, score_secondary_display desc NULLS LAST')
        end
      end

      context 'when challenge_round sort orders are descending / ascending' do
        before { challenge_round.update!(primary_sort_order: :descending, secondary_sort_order: :ascending) }

        it 'orders by score_display descending and score_secondary_display ascending' do
          expect(result).to eq('score_display desc NULLS LAST, score_secondary_display asc NULLS LAST')
        end
      end

      context 'when challenge_round sort orders are descending / not_used' do
        before { challenge_round.update!(primary_sort_order: :descending, secondary_sort_order: :not_used) }

        it 'orders only by score_display descending' do
          expect(result).to eq('score_display desc NULLS LAST')
        end
      end

      context 'when challenge_round sort orders are ascending / ascending' do
        before { challenge_round.update!(primary_sort_order: :ascending, secondary_sort_order: :ascending) }

        it 'orders by score_display ascending and score_secondary_display ascending' do
          expect(result).to eq('score_display asc NULLS LAST, score_secondary_display asc NULLS LAST')
        end
      end

      context 'when challenge_round sort orders are ascending / descending' do
        before { challenge_round.update!(primary_sort_order: :ascending, secondary_sort_order: :descending) }

        it 'orders by score_display ascending and score_secondary_display descending' do
          expect(result).to eq('score_display asc NULLS LAST, score_secondary_display desc NULLS LAST')
        end
      end

      context 'when challenge_round sort orders are ascending / not_used' do
        before { challenge_round.update!(primary_sort_order: :ascending, secondary_sort_order: :not_used) }

        it 'orders only by score_display ascending' do
          expect(result).to eq('score_display asc NULLS LAST')
        end
      end
    end
  end
end
