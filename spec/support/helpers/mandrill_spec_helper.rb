# frozen_string_literal: true

class MandrillSpecHelper
  def initialize(result)
    @res = result[0][0]
    @msg = result[1]
  end

  def status
    @res["status"]
  end

  def reject_reason
    @res["reject_reason"]
  end

  def merge_vars
    @msg[:global_merge_vars]
  end

  def merge_var(var)
    ret = nil
    merge_vars.each do |pair|
      ret = pair[:content] if pair[:name] == var
    end
    return ret
  end

  def subject
    @msg[:subject]
  end

  def from_name
    @msg[:from_name]
  end

  def from_email
    @msg[:from_email]
  end

  def email_array
    @msg[:to].map { |e| e[:email] }
  end

  def unsubscribe_url
    merge_var('UNSUBSCRIBE_URL')
  end
end
