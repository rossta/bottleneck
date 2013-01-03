source 'https://rubygems.org'

gem 'rails', '3.2.9'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "zurb-foundation", ">= 3.2.3"
  gem "compass-rails", ">= 1.0.3"
  gem "d3_rails"
  gem "jquery-ui-rails"
end

gem 'jquery-rails'

gem "thin", ">= 1.5.0"
gem "pg", ">= 0.14.1"

gem "sendgrid", ">= 1.0.1"
gem "devise", ">= 2.1.2"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.2.0"
gem "simple_form", ">= 2.0.4"
gem "figaro", ">= 0.5.0"

gem "virtus"
gem "active_model_serializers"
gem "dalli"
gem 'redis-objects', "~> 0.6"
gem 'ruby-trello', git: 'git://github.com/jeremytregunna/ruby-trello.git', branch: "master"

group :development, :test do
  gem "factory_girl_rails", ">= 4.1.0"
  gem "rspec-rails", ">= 2.11.4"
  gem "ffaker"
  gem "launchy"
  gem "debugger", git: 'git://github.com/cldwalker/debugger.git'
end

group :development do
  gem "binding_of_caller", ">= 0.6.8"
  gem "better_errors", ">= 0.2.0"
  gem "quiet_assets", ">= 1.0.1"
  gem "foreman"
  gem "supporting_cast", path: "~/projects/supporting_cast", branch: "master"
end

group :test do
  gem "capybara", ">= 2.0.1"
  gem "database_cleaner", ">= 0.9.1"
  gem "email_spec", ">= 1.4.0"
  gem "shoulda-matchers"
  gem "vcr", '~> 2.3'
  gem "fakeweb"
  # gem "poltergeist" Capybara 2 compatability coming soon: https://github.com/jonleighton/poltergeist/pull/208
end
