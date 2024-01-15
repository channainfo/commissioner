module SpreeCmCommissioner
  class CheckInAbility
    include ::CanCan::Ability

    def initialize(user)
      if user.has_spree_role?('operator')
        can :create, CheckIn
      elsif user.has_spree_role?('organizer')
        can :manage, CheckIn
      else
        cannot :manage, CheckIn
      end
    end
  end
end
