module ChallengesHelper
  def participant_invitation(email:)
    participant = Participant.find_by(email: email)
    if participant.present?
      return link_to participant.name, participant_path(participant)
    else
      return 'No AIcrowd account'
    end
  end

  def status_dropdown_helper(builder:)
    challenge = builder.object
    statuses  = Challenge.statuses.hash
    statuses  = statuses.except(:running, :completed, :terminated) if challenge.challenge_rounds.none? || challenge.dataset_files.none?
    return builder.select(:status, statuses.map { |k, v| [v.humanize, k] }, {}, { class: "form-control", required: true })
  end

  def needs_to_agree_to_terms_or_rules?(challenge)
    if !policy(challenge).has_accepted_participation_terms?
      return true
    elsif !policy(challenge).has_accepted_challenge_rules?
      return true
    end

    return false
  end

  def required_terms_or_rules_path(challenge)
    if !policy(challenge).has_accepted_participation_terms?
      return url_for([challenge, ParticipationTerms.current_terms])
    elsif !policy(challenge).has_accepted_challenge_rules?
      return url_for([challenge, challenge.current_challenge_rules])
    end

    return nil
  end

  def challenge_remaining_text(challenge, challenge_round)
    case challenge.status
    when :running, :perpetual
      if remaining_time_in_days(challenge_round) >= 2
        "#{pluralize(remaining_time_in_days(challenge_round), 'day')} left"
      elsif remaining_time_in_hours(challenge_round) > 0
        "#{pluralize(remaining_time_in_hours(challenge_round), 'hour')} left &middot; Ending #{ending_dttm(challenge_round)}"
      elsif remaining_time_in_seconds(challenge_round) > 0
        "Less than 1 hour left &middot; Ending #{ending_dttm(challenge_round)}"
      else
        "Completed" # display for perpetual challenges
      end
    when :draft
      "Draft"
    when :completed
      "Completed"
    when :starting_soon
      "Starting soon"
    end
  end

  def challenge_stat_count(challenge, stat_type)
    case stat_type
    when 'submission'
      formatted_count(challenge.submissions_count)
    when 'view'
      formatted_count(challenge.page_views)
    when 'participant'
      formatted_count(challenge.challenge_participants.size)
    when 'vote'
      formatted_count(challenge.vote_count)
    end
  end

  private

  def remaining_time_in_hours(challenge_round)
    (remaining_time_in_seconds(challenge_round) / (60 * 60)).floor
  end

  def remaining_time_in_days(challenge_round)
    (remaining_time_in_seconds(challenge_round) / (60 * 60 * 24)).floor
  end

  def remaining_time_in_seconds(challenge_round)
    return 0 if challenge_round.nil? || challenge_round.end_dttm.nil?

    seconds = challenge_round.end_dttm - Time.current
    seconds = 0 if seconds.nil? || seconds < 0
    return seconds
  end

  def ending_dttm(challenge_round)
    return nil if challenge_round.nil?

    challenge_round.end_dttm.strftime("%d %b %H:%M UTC")
  end

  def formatted_count(counter)
    if counter > 10000
      "#{format('%.1f', counter / 1000.0).chomp('.0')}k"
    else
      counter
    end
  end
end
