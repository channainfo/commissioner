source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

group :development do
  gem 'brakeman'
end

group :development, :test do
  # modify spree_dev_tools to stop using deprecated default_country_id
  gem 'spree_dev_tools', github: 'kimsrung/spree_dev_tools'

  # enforce rails best practice with rubocop
  gem 'rubocop',             '~> 1.45', require: false
  gem 'rubocop-performance', '~> 1.16', require: false
  gem 'rubocop-rails',       '~> 2.17', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'terminal-table', '~> 3.0.1'
  # ActionMailer, Net::SMTP
  gem 'net-smtp'

  gem 'rails-controller-testing'
  gem 'vcr'
  gem 'webmock'
end

gem 'spree_reviews', github: 'bookmebus/spree_reviews', branch: 'spree-4-5-0-only-backend'

gemspec
