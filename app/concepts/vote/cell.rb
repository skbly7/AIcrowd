class Vote::Cell < Template::Cell

  def show
    render
  end

  def votable
    model
  end

  def vote_link
    if current_participant.nil?
      sign_in_link
    else
      vote = votable.votes.where(participant_id: current_participant.id).first
      if vote.nil?
        upvote_link
      else
        unvote_link(vote)
        # disabled_vote_link
      end
    end
  end

  def refresh
    #{}%{ console.log("#{j(show)}")}
    %{ $('##{vote_link_id}').replaceWith("#{j(show)}"); }
  end

  def participant_voted?
    return false if current_participant.nil?
    vote = votable.votes.where(participant_id: current_participant.id).first
    return true if vote.present?
    return false
  end

  def display_vote_count
    return nil if votable.vote_count == 0
    " #{votable.vote_count}".html_safe
  end

  def upvote_link
    link_to "<button type='button' class='btn btn-secondary btn-sm'>
            <svg width='12' height='11' xmlns='http://www.w3.org/2000/svg'><path d='M10.8746251 6.14539024L5.97691577 11.0430996 1.07920644 6.14539024C.43154568 5.50196808.03030318 4.61061457.03030318 3.62554576c0-1.96049121 1.58929212-3.54978364 3.54978364-3.54978364.92305599 0 1.76382467.35231416 2.39516959.92980603.63649437-.6044087 1.49691101-.97526512 2.44394586-.97526512 1.96049123 0 3.54978363 1.58929242 3.54978363 3.54978364 0 1.00819292-.4203017 1.91821904-1.0952455 2.56441886z' fill='#F0524D' fill-rule='evenodd'></svg>
            #{display_vote_count}
            </button>".html_safe,
            eval(create_vote_path),
            id: vote_link_id,
            method: :post,
            remote: true
  end

  def vote_link_id
    "vote-link-#{votable.model_name.param_key}-#{model.id}"
  end

  def create_vote_path
    "#{votable.model_name.param_key}_votes_path(#{votable.id})"
  end

  def destroy_vote_path(votable, vote_id)
    "#{votable.model_name.param_key}_vote_path(#{votable.id},#{vote_id})"
  end

  def disabled_vote_link
    link_to "<button type='button' class='btn btn-secondary btn-sm'>
            <svg width='12' height='11' xmlns='http://www.w3.org/2000/svg'><path d='M10.8746251 6.14539024L5.97691577 11.0430996 1.07920644 6.14539024C.43154568 5.50196808.03030318 4.61061457.03030318 3.62554576c0-1.96049121 1.58929212-3.54978364 3.54978364-3.54978364.92305599 0 1.76382467.35231416 2.39516959.92980603.63649437-.6044087 1.49691101-.97526512 2.44394586-.97526512 1.96049123 0 3.54978363 1.58929242 3.54978363 3.54978364 0 1.00819292-.4203017 1.91821904-1.0952455 2.56441886z' fill='#F0524D' fill-rule='evenodd'></svg>
            #{display_vote_count}
            </button>".html_safe,
            '#',
            id: vote_link_id
  end

  def unvote_link(vote)
    link_to "<button type='button' class='btn btn-secondary btn-sm'>
            <svg width='12' height='11' xmlns='http://www.w3.org/2000/svg'><path d='M10.8746251 6.14539024L5.97691577 11.0430996 1.07920644 6.14539024C.43154568 5.50196808.03030318 4.61061457.03030318 3.62554576c0-1.96049121 1.58929212-3.54978364 3.54978364-3.54978364.92305599 0 1.76382467.35231416 2.39516959.92980603.63649437-.6044087 1.49691101-.97526512 2.44394586-.97526512 1.96049123 0 3.54978363 1.58929242 3.54978363 3.54978364 0 1.00819292-.4203017 1.91821904-1.0952455 2.56441886z' fill='#F0524D' fill-rule='evenodd'></svg>
            #{display_vote_count}
            </button>".html_safe,
            eval(destroy_vote_path(votable, vote.id)),
            id: vote_link_id,
            method: :delete,
            remote: true
  end

  def sign_in_link
    link_to "<button type='button' class='btn btn-secondary btn-sm'>
            <svg width='12' height='11' xmlns='http://www.w3.org/2000/svg'><path d='M10.8746251 6.14539024L5.97691577 11.0430996 1.07920644 6.14539024C.43154568 5.50196808.03030318 4.61061457.03030318 3.62554576c0-1.96049121 1.58929212-3.54978364 3.54978364-3.54978364.92305599 0 1.76382467.35231416 2.39516959.92980603.63649437-.6044087 1.49691101-.97526512 2.44394586-.97526512 1.96049123 0 3.54978363 1.58929242 3.54978363 3.54978364 0 1.00819292-.4203017 1.91821904-1.0952455 2.56441886z' fill='#F0524D' fill-rule='evenodd'></svg>
            #{display_vote_count}
            </button>".html_safe,
            new_participant_session_path,
            id: vote_link_id
  end

end
