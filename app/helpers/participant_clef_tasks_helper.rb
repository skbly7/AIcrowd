module ParticipantClefTasksHelper
  def participant_clef_task_status_button(participant_clef_task, challenge_id)
    participant = participant_clef_task.participant

    case participant_clef_task.status_cd
    when 'requested'
      return "<button class='btn btn-small btn-default'>EUA downloaded</button>".html_safe
    when 'submitted'
      return "<button class='btn btn-small btn-default'>Submitted [Cant approve for unknown user]</button>".html_safe if participant.nil?
      return "<button class='btn btn-small btn-default'>Missing</button>".html_safe if participant_clef_task.eua_file.blank?

      return (link_to 'Approve', participant_clef_task_path(participant_clef_task.clef_task, participant_id: participant.id, challenge_id: challenge_id), method: :patch, remote: true, class: 'btn btn-small btn-primary').to_s
    when 'registered'
      return "<button class='btn btn-small btn-default'>Approved</button>".html_safe
    end
  end

  def render_challenge_resources(participant_clef_task, clef_task, challenge)
    participant_clef_task_status = participant_clef_task_status(participant_clef_task)

    case participant_clef_task_status
    when 'profile_incomplete'
      render partial: 'task_dataset_files/resources/profile_incomplete', locals: { organizer: clef_task.organizer }
    when 'unregistered', 'requested'
      render partial: 'task_dataset_files/resources/participant_unregistered', locals: { clef_task: clef_task, challenge_id: challenge.id }
    when 'submitted'
      render partial: 'task_dataset_files/resources/participant_submitted', locals: { clef_task: clef_task, participant_clef_task: participant_clef_task, challenge_id: challenge.id }
    when 'registered'
      render partial: 'task_dataset_files/resources/task_dataset_files', locals: { clef_task: clef_task, challenge: challenge }
    end
  end

  private

  def participant_clef_task_status(participant_clef_task)
    return 'profile_incomplete' if profile_incomplete?

    if participant_clef_task.present?
      return participant_clef_task.status_cd
    else
      return 'unregistered'
    end
  end

  def profile_incomplete?
    if current_participant.first_name.blank?  ||
       current_participant.last_name.blank?   ||
       current_participant.affiliation.blank? ||
       current_participant.address.blank?     ||
       current_participant.city.blank?        ||
       current_participant.country_cd.blank?

      true
    else
      false
    end
  end
end
