# Enable tab completion
require 'irb/completion'

app = Rails.application.class.name.split('::').first
env = Rails.env

# Define a custom prompt
# Eg:
#   my_app (development) >
IRB.conf[:PROMPT]           ||= {}
IRB.conf[:PROMPT][:RAILS_APP] = {
  PROMPT_I: "AIcrowd (#{env}) > ",
  PROMPT_N: nil,
  PROMPT_S: nil,
  PROMPT_C: nil,
  RETURN:   "=> %s\n"
}

# Use the custom  prompt
IRB.conf[:PROMPT_MODE] = :RAILS_APP

unless Rails.env.production?
  require 'irbtools'
  # Save commands in `~/.app-env-irb-history`
  IRB.conf[:HISTORY_FILE] = File.expand_path("~/.#{app}-#{env}-irb-history")
  # Save 2000 lines of command history
  IRB.conf[:SAVE_HISTORY] = 2000
end
