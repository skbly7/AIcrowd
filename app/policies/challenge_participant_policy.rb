class ChallengeParticipantPolicy < ChallengePolicy
  def update?
    participant && (participant.admin? || @record.participant_id == participant.id)
  end
end
