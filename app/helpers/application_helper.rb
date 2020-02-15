module ApplicationHelper
  def rewrite_type(key)
    case key
    when 'notice'
      'success'
    when 'success'
      'success'
    when 'info'
      'info'
    when 'alert'
      'warning'
    when 'error'
      'warning'
    when 'flash'
      'flash'
    end
  end

  def body_id
    if (controller.controller_name == 'landing_page' && controller.action_name == 'index') ||
       (controller.controller_name == 'blogs' && controller.action_name == 'index')
      return 'home'
    else
      return nil
    end
  end

  def footer_class
    if controller.controller_name == 'registrations' ||
        (controller.controller_name == 'challenges' && controller.action_name == 'edit') ||
        (controller.controller_name == 'organizers' && controller.action_name == 'edit') ||
        (controller.controller_name == 'sessions')
      return "class='no-margin-top'"
    else
      return nil
    end
  end

  def themed_button(opts = {})
    raise ArgumentError if opts.key?(:link) && opts.key?(:modal)

    title = opts[:title].presence || '&nbsp;'.html_safe
    unless opts[:disabled]
      confirm = opts[:confirm]
      modal   = opts[:modal] if opts[:modal]
      if opts[:link]
        url    = begin
                opts.dig(:link, :url)
                 rescue StandardError
                   nil || opts.dig(:link)
              end
        method = begin
                   opts.dig(:link, :method)
                 rescue StandardError
                   nil || :get
                 end
      end
    end

    outer         = {}
    outer[:class] = opts[:class] if opts[:class]
    if opts[:tooltip]
      outer.deep_merge!({
                          title: opts[:tooltip],
                          data:  {
                            toggle: 'tooltip'
                          }
                        })
    end

    inner_type = :button
    inner      = {
      disabled: opts[:disabled],
      class:    "btn btn-secondary"
    }
    inner[:class] += ' disabled' if opts[:disabled]
    inner[:class] += ' btn-sm' if opts[:small]
    if url
      inner_type = :a
      inner.deep_merge!({
                          href: url,
                          data: {
                            method: method,
                            **(confirm ? { confirm: confirm } : {})
                          }
                        })
    elsif modal
      inner.deep_merge!({
                          type: 'button',
                          data: {
                            toggle: 'modal',
                            target: modal
                          }
                        })
    end

    content_tag(:span, outer) { content_tag(inner_type, inner) { title } }
  end
end
