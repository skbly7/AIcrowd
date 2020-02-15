class OrganizerApplicationNotificationMailer < ApplicationMailer
  def sendmail(organizer_application)
    options = format_options(organizer_application)
    mandrill_send(options)
  end

  def format_options(organizer_application)
    options = {
      participant_id:    nil,
      subject:           "Organizer Application Received",
      to:                organizer_application.email,
      template:          "AIcrowd General Template",
      global_merge_vars: [
        {
          name:    "NAME",
          content: organizer_application.contact_name.to_s
        },
        {
          name:    "BODY",
          content: email_body(organizer_application)
        },
        { name:    'EMAIL_PREFERENCES_LINK',
          content: EmailPreferencesTokenService
                            .new(participant)
                            .email_preferences_link }
      ]
    }
  end

  def email_body(organizer_application)
    "<div>" +
      "<h3>Organizer Application received.</h3>" +
      "<p>We have received your application to become a AIcrowd organizer. You will be contacted by a member of our team.</p>" +
      "<ul>" +
      "<li><b>Organization:</b> #{organizer_application.organization}</li>" +
      "<li><b>Contact Name:</b> #{organizer_application.contact_name}</li>" +
      "<li><b>Phone:</b> #{organizer_application.phone}</li>" +
      "<li><b>Email:</b> #{organizer_application.email}</li>" +
      "</ul>" +
      "<p>#{organizer_application.organization_description}</p>" +
      "<hr/>" +
      "<p>#{organizer_application.challenge_description}</p>" +
      "</div>"
  end
end
