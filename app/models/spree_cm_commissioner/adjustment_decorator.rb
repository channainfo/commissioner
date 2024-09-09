module SpreeCmCommissioner
  module AdjustmentDecorator
    def self.prepended(base)
      base.belongs_to :payable, polymorphic: true, optional: true

      base.whitelisted_ransackable_attributes |= %w[payable_id]
    end

    def display_negative_amount
      "#{amount} #{Money::Currency.find(currency).symbol}"
    end
  end
end

unless Spree::Adjustment.included_modules.include?(SpreeCmCommissioner::AdjustmentDecorator)
  Spree::Adjustment.prepend(SpreeCmCommissioner::AdjustmentDecorator)
end
