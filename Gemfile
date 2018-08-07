source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '~> 5.2.0'
gem 'resque'
gem 'activerecord-import'
gem 'active_model_serializers'
gem 'activerecord-session_store'
gem 'acts_as_list'
gem 'addressable'
gem 'angularjs-rails', '~> 1.4.2'
gem 'angular-rails-templates'

# zip utility for simple creation of zip files, pure ruby implementation
# without the GC overhead of the Rubyzip library
gem 'archive-zip', '~> 0.7.0'

gem 'autonumeric-rails'
gem 'autoprefixer-rails', '~> 8.0'
gem 'aws-sdk', '~> 2'
gem 'bootsnap'
gem 's3_direct_upload'
gem 'cancancan'
gem 'carrierwave'
gem 'coffee-rails'
gem 'croutons'
gem 'd3-rails'
gem 'dalli'

# adds expect{something}.to 'make_database_queries' matchers to rspec
# useful for testing eager/lazy loading
gem 'db-query-matchers'

gem 'dotenv-rails'

gem 'fast_blank'
gem 'fog-aws'
gem 'font-awesome-rails', '~> 4.7'
gem 'google-api-client', '~> 0.11'
gem 'haml'
gem 'httparty'
gem 'ims-lti', '~> 1.1.13'
gem 'jbuilder'
gem 'jquery-rails'

gem 'light-service'

gem 'multi_json'
gem 'mini_magick'
gem 'mongoid', '~> 6.0.0'
gem 'namae'
gem 'ng-rails-csrf'
gem 'nokogiri'
gem 'oauth', '~> 0.5'
gem 'oink'
gem 'oj'
gem 'omniauth'
gem 'omniauth-canvas'
gem 'omniauth-google-oauth2'
gem 'omniauth-kerberos'
gem 'omniauth-lti', '~> 0.0.2'

gem 'ransack'
gem 'recaptcha', require: "recaptcha/rails"
gem 'pacecar'
gem 'paper_trail'
gem 'pg'
gem 'porch'
gem 'puma'
gem 'rack-mini-profiler', require: false
gem 'rails_autolink'
gem 'rdiscount'
gem 'redis', '~> 3.0'

# retry dsl for resque
gem 'resque-retry'

# handles deferrence of Resque jobs to a later time
# ex: Resque.enqueue_in(5.hours, @worker_object)
#
# A fix for a long-standing issue will address some of the warnings on start up
# NOTE: https://github.com/resque/resque-scheduler/issues/600
gem 'resque-scheduler', require: 'resque/scheduler'

# slightly more mature rate limiter plugin for resque
# gem 'resque-waiting-room'

# limits the number of jobs that are run per unit of time on a given queue
# ex: Resque.rate_limit(:my_queue, :at => 10, :per => 60)
gem 'resque-throttler', require: 'resque/throttler'

gem 'responders'
# when updating, version MUST be compatible with ng-rollbar and rollbar.js dependencies
gem 'rollbar', '~> 2.1'
gem 'sampler'
gem 'sanitize'
gem 'sassc-rails'

# secure crypt hashing library stronger than bcrypt or PBDBF2
gem 'scrypt', '2.0.2'

gem 'select2-rails'
gem 'simple_form'
gem 'sorcery'
gem 'uglifier', '~> 3.2'
gem 'underscore-rails'
gem 'whenever'
gem 'newrelic_rpm'
gem 'wysiwyg-rails'
gem 'ruby-saml'

group :development do
  gem 'haml-rails'
  gem 'valid_attribute'
  gem 'foreman'
  gem 'rubystats'
  gem 'bullet'
  gem 'lol_dba'
  gem 'rubocop'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'jasmine-rails'
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem 'database_cleaner', '~> 1.7'
  gem 'faker'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'capybara-select2'
  gem 'launchy'
  gem 'rails-controller-testing', require: false
  gem 'rspec-rails'
  # add spec helpers for testing Resque objects and resque scheduler
  gem 'resque_spec', git: 'https://github.com/leshill/resque_spec.git', branch: 'master'
  gem 'rspec-html-matchers'
  gem 'simplecov'
  gem 'webmock'
end

group :tasks do
  gem 'rake-hooks'
end

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '1.3.15'
  gem 'rails-assets-angular-resource', '1.3.15'
  gem 'rails-assets-lodash', '3.7.0'
  gem 'rails-assets-jquery', '2.1.4'
  gem 'rails-assets-angular-dragdrop', '1.0.11'
  gem 'rails-assets-ngDraggable', '0.1.8'
  gem 'rails-assets-rollbar.js', '~> 2.3.9'
  gem 'rails-assets-ng-rollbar', '~> 2.3.10'
end
