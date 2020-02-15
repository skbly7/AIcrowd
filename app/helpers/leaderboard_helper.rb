module LeaderboardHelper
  def status_badge(status)
    case status
    when 'ready', 'submitted', 'initialized'
      klass = 'badge-amber'
    when 'graded'
      klass = 'badge-green'
    when 'failed'
      klass = 'badge-red'
    else
      klass = 'badge-amber'
    end

    %(
      <div class="#{klass}">
        <span class="badge-square"></span>
        <span class="badge-text">
          #{status.capitalize}
        </span>
      </div>
    ).html_safe
  end

  def leaderboard_ranking_change(leaderboard)
    if leaderboard.previous_row_num.blank? ||
         leaderboard.previous_row_num == 0 ||
         leaderboard.previous_row_num == leaderboard.row_num

      return image_tag(
        "icon-change-none.svg",
        data: { toggle: 'tooltip' },
        title: 'No change')
    end

    if leaderboard.row_num > leaderboard.previous_row_num
      return image_tag("icon-change-down.svg",
        data:  { toggle: 'tooltip' },
        title: "-#{leaderboard.row_num - leaderboard.previous_row_num} change, previous rank #{leaderboard.previous_row_num}")
    end

    if leaderboard.row_num < leaderboard.previous_row_num && leaderboard.previous_row_num != 0
      return image_tag(
        "icon-change-up.svg",
        data:  { toggle: 'tooltip' },
        title: "+#{leaderboard.previous_row_num - leaderboard.row_num} change, previous rank #{leaderboard.previous_row_num}")
    end
  end

  def leaderboard_participants(leaderboard)
    temp_participants = begin
      if leaderboard.try(:submitter_type) == 'Team'
        leaderboard&.team&.participants&.to_a
      else
        [leaderboard&.participant]
      end
    end

    temp_participants = [] if temp_participants.nil? || temp_participants.include?(nil)
    return temp_participants
  end

  def leaderboard_formatted_value(challenge_round, value)
    format("%.#{challenge_round.score_precision}f", value || 0)
  end

  def leaderboard_other_scores_array(leaderboard, challenge)
    other_scores = []
    challenge.other_scores_fieldnames_array.each do |fname|
      other_scores << if leaderboard.meta && (leaderboard.meta.key? fname)
                        (leaderboard.meta[fname].nil? ? "-" : format("%.3f", leaderboard.meta[fname].to_f))
                      else
                        '-'
                      end
    end
    return other_scores
  end

  def leaderboard_tab_classes(challenge_round, current_round)
    if challenge_round.id == current_round.id
      return 'nav-link active'
    else
      return 'nav-link'
    end
  end
end
