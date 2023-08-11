module SpreeCmCommissioner
  module AdjustmentDecorator
    def self.prepended(base)
      base.attr_accessor :current_user_instance

      base.belongs_to :payable, polymorphic: true, optional: true

      base.before_save :set_payable

      base.whitelisted_ransackable_attributes |= %w[payable_id]
    end

    # must set current_user_instance
    # before hand
    def set_payable
      self.payable = current_user_instance.presence
    end
  end
end

unless Spree::Adjustment.included_modules.include?(SpreeCmCommissioner::AdjustmentDecorator)
  Spree::Adjustment.prepend(SpreeCmCommissioner::AdjustmentDecorator)
end
