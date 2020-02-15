require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'selenium/webdriver'

Capybara::Screenshot.prune_strategy = { keep: 20 }

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  filename = File.basename(path)
  driver.browser.save_screenshot("#{Rails.root}/tmp/capybara/#{filename}")
end

Capybara.register_driver(:selenium) do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(args: ['headless', 'disable-gpu', 'window-size=1920,1080'])
  )
end

Capybara.reset_sessions!
Capybara.ignore_hidden_elements = true
