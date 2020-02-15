module FollowsHelper
  def follow_link_id(followable)
    "follow-link-#{followable.class.to_s.downcase}-#{followable.id}"
  end

  def follows_create_follow_path(followable)
    url_helper_method_name = "#{followable.model_name.param_key}_follows_path"

    Rails.application.routes.url_helpers.public_send(url_helper_method_name, followable.id)
  end

  def follows_destroy_follow_path(followable, follow_id)
    url_helper_method_name = "#{followable.model_name.param_key}_follow_path"

    Rails.application.routes.url_helpers.public_send(url_helper_method_name, followable.id, follow_id)
  end
end
