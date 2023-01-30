source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

spree_opts = '~> 4.5.0'
gem 'spree', spree_opts
gem 'spree_api', spree_opts
gem 'spree_auth_devise'
gem 'spree_backend', spree_opts
gem 'spree_multi_vendor'
gem 'spree_api_v1'  # latest spree_multi_vendor 2.4.0 still depends on the Spree v1 API

gem 'elasticsearch', '~> 8.5'
gem 'searchkick',    '~> 5.1'

gem 'interactor', '~> 3.1'
gem 'jwt'

group :development do
  gem 'brakeman'
end

group :test do
  gem 'byebug'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'terminal-table', '~> 3.0.1'
  # ActionMailer, Net::SMTP
  gem 'net-smtp'

  gem 'rails-controller-testing'
  gem 'rubocop-rails'
end

gemspec
