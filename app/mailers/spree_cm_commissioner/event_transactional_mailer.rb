module SpreeCmCommissioner
  class EventTransactionalMailer < Spree::BaseMailer
    layout 'spree_cm_commissioner/layouts/event_transactional_mailer'

    def send_to_organizer(event_id, organizer_id)
      @organizer = Spree::User.find(organizer_id)
      @event = Spree::Taxon.find(event_id)

      subject = t('mail.event_engagement_mailer.organizer.subject', event_name: @event.name)

      mail(from: from_address, to: @organizer.email, subject: subject)
    end

    def send_to_participant(event_id, participant_id)
      @participant = Spree::User.find(participant_id)
      @event = Spree::Taxon.find(event_id)

      subject = I18n.t('mail.event_engagement_mailer.participant.subject', event_name: @event.name)

      mail(from: from_address, to: @participant.email, subject: subject)
    end
  end
end
