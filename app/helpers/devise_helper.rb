module DeviseHelper
  def devise_mapping
    Devise.mappings[:participant]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html     = <<-HTML
   <div class="alert alert-warning alert-dismissible fade show" role="alert">
    <div class="container-fluid">
      #{messages}
      <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
  </div>
    HTML

    html.html_safe
 end
end
