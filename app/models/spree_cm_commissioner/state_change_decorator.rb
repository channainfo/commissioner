module SpreeCmCommissioner
  module StateChangeDecorator
    def self.prepended(base)
      base.before_save :set_user_by_current_user_instance, if: :payment?
    end

    private

    # must set current_user_instance
    # before hand
    def set_user_by_current_user_instance
      assign_attributes(user: stateful.current_user_instance)
    end

    def payment?
      stateful.is_a?(Spree::Payment)
    end
  end
end

unless Spree::StateChange.included_modules.include?(SpreeCmCommissioner::StateChangeDecorator)
  Spree::StateChange.prepend(SpreeCmCommissioner::StateChangeDecorator)
end
