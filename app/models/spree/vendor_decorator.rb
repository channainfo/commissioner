module Spree
  module VendorDecorator
    def self.prepended(base)
      base.has_many :photos, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorPhoto'
      base.has_many :option_values, through: :products
      base.has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::VendorLogo'

      if base.method_defined?(:whitelisted_ransackable_associations)
        if base.whitelisted_ransackable_associations
          base.whitelisted_ransackable_associations |= %w[option_values]
        else
          base.whitelisted_ransackable_associations = %w[option_values]
        end
      end
    end
  end
end

Spree::Vendor.prepend Spree::VendorDecorator
