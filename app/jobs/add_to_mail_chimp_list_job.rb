class AddToMailChimpListJob < ApplicationJob
  queue_as :default

  def perform(participant_id)
    participant                         = Participant.find(participant_id)
    lower_case_md5_hashed_email_address = Digest::MD5.hexdigest(participant.email.downcase)
    begin
      gibbon = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
      resp   = gibbon.lists(ENV['MAILCHIMP_LIST_ID'])
                   .members(lower_case_md5_hashed_email_address)
                   .upsert(body: {
                            email_address: participant.email,
                            status:        'subscribed',
                            merge_fields:  { FNAME: participant.name }
                          })
    rescue Exception => e
      participant.disable_account('MailChimp rejected email as a fake address') if e.message =~ /ooks fake or invalid, please enter a real email address/
    end
    logger.info("AddToMailChimpListJob API response: #{resp}")
  end
end
