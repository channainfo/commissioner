module SpreeCmCommissioner
  class TransactionalEmailSender < BaseInteractor
    delegate :event_id, :recipient_id, :type, to: :context

    def call
      context.fail!(message: 'Email already sent') if email_already_sent?
      context.fail!(message: 'Banner Image required') unless banner_image_attached?

      send_email
      update_sent_at
    end

    private

    def transactional_email
      @transactional_email ||= SpreeCmCommissioner::TransactionalEmail.find_or_initialize_by(
        taxon_id: event_id,
        recipient_id: recipient_id,
        recipient_type: 'Spree::User'
      )
    end

    def update_sent_at
      transactional_email.update!(sent_at: Time.current)
    end

    def email_already_sent?
      transactional_email.sent_at.present?
    end

    def banner_image_attached?
      event.home_banner&.attachment&.attached?
    end

    def event
      @event ||= Spree::Taxon.event.find(event_id)
    end

    def send_email
      case type.to_sym
      when :organizer
        SpreeCmCommissioner::EventTransactionalMailer.send_to_organizer(event_id, recipient_id).deliver_later
      when :participant
        SpreeCmCommissioner::EventTransactionalMailer.send_to_participant(event_id, recipient_id).deliver_later
      else
        context.fail!(message: "Unknown transactional email type: #{type}")
      end
    end
  end
end
