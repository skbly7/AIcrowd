module ApiKey
  def set_api_key
    self.api_key = generate_api_key if api_key.blank?
  end

  def generate_api_key
    api_key = nil
    begin
      api_key = SecureRandom.hex
    end while (Participant.exists?(api_key: api_key) || Organizer.exists?(api_key: api_key))
    return api_key
  end
end
