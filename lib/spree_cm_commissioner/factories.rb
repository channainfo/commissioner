require 'factory_bot'

Spree::Zone.class_eval do
  def self.global
    find_by(name: 'GlobalZone') || FactoryBot.create(:global_zone)
  end
end

Dir["#{File.dirname(__FILE__)}/test_helper/factories/**"].each do |f|
  load File.expand_path(f)
end

FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_cm_commissioner/factories'
end
