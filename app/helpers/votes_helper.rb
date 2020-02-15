module VotesHelper
  def votes_display_vote_count(votable)
    return nil if votable.vote_count == 0

    " #{votable.vote_count}"
  end

  def votes_create_vote_path(votable)
    url_helper_method_name = "#{votable.model_name.param_key}_votes_path"

    Rails.application.routes.url_helpers.public_send(url_helper_method_name, votable.id)
  end

  def votes_destroy_vote_path(votable, vote_id)
    url_helper_method_name = "#{votable.model_name.param_key}_vote_path"

    Rails.application.routes.url_helpers.public_send(url_helper_method_name, votable.id, vote_id)
  end

  def votes_link_id(votable)
    "vote-link-#{votable.model_name.param_key}-#{votable.id}"
  end
end
