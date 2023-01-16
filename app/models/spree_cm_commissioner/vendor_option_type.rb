require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class VendorOptionType < ApplicationRecord
    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy
    belongs_to :option_type, class_name: 'Spree::OptionType', dependent: :destroy
  end
end

