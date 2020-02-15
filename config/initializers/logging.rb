ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) unless Rails.env.test?
