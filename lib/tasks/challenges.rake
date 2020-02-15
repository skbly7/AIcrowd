namespace :challenges do
  desc "Migrate challenges score titles to rounds score titles"
  task migrate_score_titles_to_rounds: :environment do
    Challenge.includes(:challenge_rounds).find_each do |challenge|
      next if challenge.score_title.blank? &&
        challenge.score_secondary_title.blank? &&
        challenge.primary_sort_order_cd.blank? &&
        challenge.secondary_sort_order_cd.blank?

      challenge.challenge_rounds.update_all(
        score_title:              challenge.score_title,
        score_secondary_title:    challenge.score_secondary_title,
        primary_sort_order_cd:    challenge.primary_sort_order_cd,
        secondary_sort_order_cd:  challenge.secondary_sort_order_cd
      )

      puts "##{challenge.id} Challenge - finished migration of score titles."
    end
  end
end
