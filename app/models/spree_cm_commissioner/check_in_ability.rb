module SpreeCmCommissioner
  class CheckInAbility
    include ::CanCan::Ability

    def initialize(user)
      if user.has_spree_role?('operator')
        can :manage, CheckIn
      elsif user.has_spree_role?('organizer')
        can :manage, CheckIn
        can :manage, Guest
      else
        cannot :manage, CheckIn
      end
    end
  end
end
