# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'rspec/autorun'
require 'capybara/mechanize'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# require 'capybara/poltergeist'
# Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include FactoryGirl::Syntax::Methods
  config.include Warden::Test::Helpers, type: :feature
  config.include DomHelpers, type: :feature
  config.include AuthHelpers, type: :feature

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.order = "random"

  config.before(:suite) do
    Warden.test_mode!
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    Redis.current.flushdb
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
