module SpreeCmCommissioner
  class CheckInRecordAbility
    include ::CanCan::Ability

    def initialize(user)
      if user.has_spree_role?('operator')
        can :create, CheckInRecord
      elsif user.has_spree_role?('organizer')
        can :manage, CheckInRecord
      else
        cannot :manage, CheckInRecord
      end
    end
  end
end
