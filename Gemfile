# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0'

gem 'rails', '~> 6.0.0'                               # The newest version of rails
gem "pg", "~> 1.1"                                    # PG database
gem 'puma', '~> 3.11'                                 # Use Puma as the app server
gem 'bcrypt', '~> 3.1.7'                              # Use ActiveModel has_secure_password
gem 'geocoder'                                        # Address to Latitude/Longitude
gem 'rack-cors', require: 'rack/cors'                 # Makes cross-origin AJAX possible
gem 'sidekiq'                                         # Run jobs in the background
gem 'paranoia'                                        # Soft-deleting models
gem 'rack-timeout'                                    # Time out long-running requests
gem 'activerecord-import'                             # Bulk insert
gem 'retriable'                                       # Retry failed actions max N times
gem 'migration_data'
gem 'upsert'                                          # SQL upsert queries
gem 'sendgrid-actionmailer'                           # adds transparency for actionmailer to use sendgrid Web API
gem 'dotenv-rails'                                    # Load env vars from .env

gem 'bootsnap', '>= 1.1.0', require: false            # Reduces boot times through caching; required in config/boot.rb

gem 'core', :git => 'https://Brokrete:9c69a21f39629f5286d395d4dcfd101cdcf902e4@github.com/Brokrete/brokrete-server-core.git', :branch => 'master'

gem 'graphql'                                         # GraphQL implementation
gem 'graphql-errors'
gem 'phonelib'                                        # Validating phone number
gem 'jwt'                                             # JWT
gem 'virtus'
gem 'twilio-ruby'                                     # Twilio client
gem 'stoplight'
gem 'sendgrid-ruby'
gem 'stripe'                                          # Payments
gem 'geokit-rails'
gem 'rrule'

group :development, :test do
  gem 'byebug', platform: [:mri, :mingw, :x64_mingw]  # debugger
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'fluff'                                         # Run tests in parallel and display on Web UI
  gem 'bullet'                                        # help to kill N+1 queries and unused eager loading
  gem 'hashdiff', ['>= 1.0.0.beta1', '< 2.0.0']
  gem 'rubocop'                                       # Ruby linting
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'                   # Guard reload on file changes
  gem 'spring'                                        # Fast reload
  gem 'spring-watcher-listen', '~> 2.0.0'             # ^ integrate with spring
  gem 'spring-commands-rspec'                         # Spring binstub for Rspec
  gem 'rb-readline'                                   # Need to be able run rails console on my mac / mikdiet
  gem 'annotate'                                      # Annotate things!
  gem 'rest-client'                                   # HTTP client (used by load-testing)
end

group :test do
  gem 'vcr'                                           # Record and replay HTTP requests
  gem 'rspec-rails', '~> 3.8'                         # Test things!
  gem 'rspec-activemodel-mocks'                       # mock_model, stub_model
  gem 'factory_bot_rails'                             # Create test models
  gem 'webmock'                                       # Stub and mock HTTP requests & disable_net_connect!
  gem 'shoulda-matchers'                              # it { validates_presence_of ... }
  gem 'zonebie'                                       # prevents bugs in code that deals with timezones
  gem 'rspec-sidekiq'                                 # let us test async tasks
  gem 'faker'                                         # generate fake user info for testing
  gem 'sqlite3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
