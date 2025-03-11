module SpreeCmCommissioner
  class CrewInviter < BaseInteractor
    delegate :id, :invitee_id, to: :context

    def call
      validate_data
      assign_role_to_user
      create_user_event
      update_invite_user_event
      context.invite = crew_invite
    end

    private

    def validate_data
      if invite_user_event.nil?
        context.fail!(message: I18n.t('invite.url_not_found'))
      elsif !invite_user_event.invite.url_valid?
        context.fail!(message: I18n.t('invite.url_expired'))
      end
    end

    def assign_role_to_user
      return if user.operator?

      role = Spree::Role.find_by(name: 'operator')
      role_user = Spree::RoleUser.new(user_id: user.id, role_id: role.id)
      role_user.save
    end

    def create_user_event
      @user_event = SpreeCmCommissioner::UserEvent.new(
        taxon_id: crew_invite.taxon_id,
        user_id: user.id
      )

      return if @user_event.save

      context.fail!(message: I18n.t('invite.already_invited'))
    end

    def update_invite_user_event
      invite_user_event.user_taxon_id = @user_event.id
      invite_user_event.confirmed_at = Time.current

      return if @invite_user_event.save

      context.fail!(message: I18n.t('invite.update_fail'))
    end

    def crew_invite
      @crew_invite ||= SpreeCmCommissioner::CrewInvite.find(id)
    end

    def invite_user_event
      @invite_user_event ||= crew_invite.invite_user_events.find_by(email: user.email, confirmed_at: nil)
    end

    def user
      @user ||= Spree::User.find(invitee_id)
    end
  end
end
