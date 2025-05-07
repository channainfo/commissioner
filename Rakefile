require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'spree/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default do
  if Dir['spec/dummy'].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir('../../')
  end
  Rake::Task[:spec].invoke
end

# Copied from:
# spree_core:lib/spree/testing_support/common_rake.rb
# But refactored to skip frontend & backend setup.
desc 'Generates a dummy app for testing'
task :test_app do |_t, args|
  require 'spree_cm_commissioner'
  require "generators/spree_cm_commissioner/install/install_generator"

  Rails.env = ENV['RAILS_ENV'] = 'test'

  Spree::DummyGeneratorHelper.inject_extension_requirements = true
  Spree::DummyGenerator.start ["--lib_name=spree_cm_commissioner", '--quiet']
  Spree::InstallGenerator.start [
    "--lib_name=spree_cm_commissioner",
    '--auto-accept',
    '--migrate=false',
    '--seed=false',
    '--sample=false',
    '--quiet',
    '--copy_storefront=false',
    "--install_storefront=false",
    "--install_admin=false",
    "--user_class=Spree::User"
  ]

  puts 'Setting up dummy database...'
  system('bin/rails db:environment:set RAILS_ENV=test')
  system('bundle exec rake db:drop db:create')
  Spree::DummyModelGenerator.start
  system('bundle exec rake db:migrate')

  puts 'Running extension installation generator...'
  SpreeCmCommissioner::Generators::InstallGenerator.start(['--auto-run-migrations'])
end
