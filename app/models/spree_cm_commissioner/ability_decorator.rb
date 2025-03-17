module SpreeCmCommissioner
  module AbilityDecorator
    private

    def abilities_to_register
      super.reject { |ability| ability == Spree::VendorAbility } << SpreeCmCommissioner::CheckInAbility
    end

    def current_ability
      @current_ability ||= ::Ability.new(spree_current_user)
    end
  end
end

Spree::Ability.prepend SpreeCmCommissioner::AbilityDecorator
