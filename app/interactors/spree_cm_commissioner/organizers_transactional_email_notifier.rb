module SpreeCmCommissioner
  class OrganizersTransactionalEmailNotifier < BaseInteractor
    delegate :event_id, to: :context

    def call
      return if organizers.empty?

      organizers.each do |organizer|
        SpreeCmCommissioner::TransactionalEmailSender.call(
          event_id: event_id,
          recipient_id: organizer.id,
          type: 'organizer'
        )
      end
    end

    private

    def event
      @event ||= Spree::Taxon.event.find(event_id)
    end

    def organizers
      @organizers ||= event.vendors.first&.users || []
    end
  end
end
