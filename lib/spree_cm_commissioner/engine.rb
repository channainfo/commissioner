module SpreeCmCommissioner
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_cm_commissioner'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_cm_commissioner.environment', before: :load_config_initializers do |_app|
      Config = Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do
      Rails.application.config.spree.promotions.rules.concat [
        SpreeCmCommissioner::Promotion::Rules::Vendors,
        SpreeCmCommissioner::Promotion::Rules::Customers,
        SpreeCmCommissioner::Promotion::Rules::FixedDate,
        SpreeCmCommissioner::Promotion::Rules::Weekend,
        SpreeCmCommissioner::Promotion::Rules::CustomDates,
        SpreeCmCommissioner::Promotion::Rules::GuestOccupations,
        SpreeCmCommissioner::Promotion::Rules::GuestAgeGroup
      ]

      Rails.application.config.spree.promotions.actions.concat [
        SpreeCmCommissioner::Promotion::Actions::CreateDateSpecificItemAdjustments,
        SpreeCmCommissioner::Promotion::Actions::CreateGuestItemAdjustments,
      ]
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
