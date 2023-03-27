require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Invoice < ApplicationRecord
    belongs_to :order, class_name: 'Spree::Order', dependent: :destroy
    belongs_to :vendor, class_name: 'Spree::Vendor', dependent: :destroy
    validates :invoice_number, presence: true, uniqueness: { scope: :vendor_id }
  end
end
