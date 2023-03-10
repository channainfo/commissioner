require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ListingPrice < ApplicationRecord
    has_many :adjustments, as: :adjustable, class_name: 'Spree::Adjustment', dependent: :destroy

    belongs_to :price_source, polymorphic: true

    validates :date, presence: true

    extend Spree::DisplayMoney
    money_methods :price, :adjustment_total, :additional_tax_total, :promo_total, :included_tax_total,
                  :pre_tax_amount, :taxable_adjustment_total, :non_taxable_adjustment_total

    alias_attribute :amount, :price
  end
end
