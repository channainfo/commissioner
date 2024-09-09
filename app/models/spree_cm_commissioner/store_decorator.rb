module SpreeCmCommissioner
  module StoreDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::StorePreference

      base.has_one :default_notification_image, class_name: 'SpreeCmCommissioner::FeatureImage', dependent: :destroy, as: :viewable
      base.accepts_nested_attributes_for :default_notification_image, reject_if: :all_blank
    end
  end
end

Spree::Store.prepend(SpreeCmCommissioner::StoreDecorator) unless Spree::Store.included_modules.include?(SpreeCmCommissioner::StoreDecorator)
