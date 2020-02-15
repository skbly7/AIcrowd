class DeviseMandrillMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  def reset_password_instructions(record, token, opts = {})
    options = {
      participant_id:    record.id,
      subject:           "AIcrowd Password Reset",
      email:             record.email,
      global_merge_vars: [
        {
          name:    "NAME",
          content: record.name
        },
        {
          name:    "RESET_PASSWORD_URL",
          content: edit_password_url(record, reset_password_token: token)
        }
      ],
      template:          "AIcrowd Devise reset_password_instructions"
    }
    mandrill_send options
  end

  def confirmation_instructions(record, token, opts = {})
    options = {
      participant_id:    record.id,
      subject:           "AIcrowd Confirmation Instructions",
      email:             record.email,
      global_merge_vars: [
        {
          name:    "NAME",
          content: record.name
        },
        {
          name:    "CONFIRMATION_URL",
          content: confirmation_url(record, confirmation_token: token)
        }
      ],
      template:          "AIcrowd Devise confirmation_instructions"
    }
    mandrill_send options
  end

  def unlock_instructions(record, token, opts = {})
    options = {
      participant_id:    record.id,
      subject:           "AIcrowd Unlock Instructions",
      email:             record.email,
      global_merge_vars: [
        {
          name:    "NAME",
          content: record.name
        },
        {
          name:    "UNLOCK_URL",
          content: unlock_url(record, unlock_token: token)
        }
      ],
      template:          "AIcrowd Devise unlock_instructions"
    }
    mandrill_send options
  end

  def mandrill_send(options = {})
    message = {
      subject:           options[:subject],
      from_name:         "AIcrowd",
      from_email:        "no-reply@aicrowd.com",
      to:                [
        {
          email: options[:email],
          type:  "to"
        }
      ],
      global_merge_vars: options[:global_merge_vars]
    }
    unless Rails.env.test?
      if delivery_method == :letter_opener
        # TODO put this logic somewhere else so that it is not semi-duplicated in application_mailer
        rendered = MANDRILL.templates.render(options[:template], [], options[:global_merge_vars])
        tmp_mail = mail(
          from:    %("#{message[:from_name].gsub('"', '&quot;')}" <#{message[:from_email]}>),
          to:      options[:email],
          subject: options[:subject]
        ) do |format|
          format.html { render(html: rendered['html'].html_safe) }
        end
        tmp_mail.deliver
      else
        MANDRILL.messages.send_template(options[:template], [], message)
      end
    end

  rescue Mandrill::Error => e
    puts e.message
    Rails.logger.debug("#{e.class}: #{e.message}")
    raise
  end
end
