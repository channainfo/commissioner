require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class OptionValueVendor < ApplicationRecord
    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy
    belongs_to :option_value, class_name: 'Spree::OptionValue', dependent: :destroy
  end
end
