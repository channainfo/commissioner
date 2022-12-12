source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

spree_opts = '>= 4.4.0'
gem 'spree', spree_opts
gem 'spree_api', spree_opts
gem 'spree_backend', spree_opts
gem 'spree_auth_devise'
gem 'spree_multi_vendor'

gem 'elasticsearch', '~> 8.5'
gem 'searchkick',    '~> 5.1'

gem 'rails-controller-testing'
gem 'jwt'
gem 'interactor', '~> 3.1'

# Temporarily for ruby 3.1. Until upgrade rails to v7.0.1+
gem "net-smtp", require: false

group :test do
  gem 'byebug'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'spree_travel_core', github: 'channainfo/spree_travel_core'
end

gemspec
