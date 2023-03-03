require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class VendorPricingRule < ApplicationRecord
    acts_as_list scope: :vendor

    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy

    attr_accessor :price_by_dates, :min_price_by_rule, :max_price_by_rule
  end
end
