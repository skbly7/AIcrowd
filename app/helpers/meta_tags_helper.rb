module MetaTagsHelper
  def meta_title
    if content_for?(:meta_title)
      content_for(:meta_title)
    elsif !@page_title.blank?
      "AIcrowd | " + @page_title
    elsif !title_from_controller_name.nil?
      "AIcrowd | " + title_from_controller_name
    else
      DEFAULT_META["meta_title"]
    end
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : DEFAULT_META["meta_description"]
  end

  def meta_image
    meta_image = (content_for?(:meta_image) ? content_for(:meta_image) : DEFAULT_META["meta_image"])
    # little twist to make it work equally with an asset or a url
    meta_image.starts_with?("http") ? meta_image : url_to_image(meta_image)
  end

  def title_from_controller_name
    case controller.controller_name
    when 'challenges'
      'Challenges'
    when 'leaderboards'
      'Leaderboard'
    when 'dataset_files'
      'Dataset'
    when 'task_dataset_files'
      'Task Dataset'
    when 'participant_challenges'
      'Participants'
    when 'winners'
      'Winners'
    when 'submissions'
      'Submissions'
    when 'clef_tasks'
      'Tasks'
    when 'blogs'
      'Blog'
    end
  end
end
