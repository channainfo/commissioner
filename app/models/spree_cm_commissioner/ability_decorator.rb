module SpreeCmCommissioner
  module AbilityDecorator
    private

    def abilities_to_register
      super << SpreeCmCommissioner::CheckInRecordAbility
    end
  end
end

Spree::Ability.prepend SpreeCmCommissioner::AbilityDecorator
