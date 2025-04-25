module SpreeCmCommissioner
  class CrewInviteMailer < Spree::BaseMailer
    layout 'spree_cm_commissioner/layouts/crew_invite_mailer'

    def send_crew_invite_email(invite_user_event_id)
      @invite_user_event = SpreeCmCommissioner::InviteUserEvent.find(invite_user_event_id)

      subject = I18n.t('mail.crew_invite_mailer.subject', event_name: @invite_user_event.invite.taxon.name)

      mail(from: from_address, to: @invite_user_event.email, subject: subject)
    end
  end
end
