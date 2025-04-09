module SpreeCmCommissioner
  class CrewInviteMailer < Spree::BaseMailer
    layout 'spree_cm_commissioner/layouts/crew_invite_mailer'

    def send_crew_invite_email(invite_user_event_id)
      @invite_user_event = SpreeCmCommissioner::InviteUserEvent.find(invite_user_event_id)

      subject = Spree::Store.default.name.to_s

      mail(from: from_address, to: @invite_user_event.email, subject: subject)
    end
  end
end
