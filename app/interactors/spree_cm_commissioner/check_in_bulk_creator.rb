module SpreeCmCommissioner
  class CheckInBulkCreator < BaseInteractor
    delegate :guest_ids, :check_in_by, to: :context

    def call
      context.fail!(message: :guest_ids_must_not_blank) if guest_ids.blank?

      ActiveRecord::Base.transaction do
        context.check_ins = guest_ids.map do |guest_id|
          create_check_in_for(guest_id)
        end
      end
    end

    private

    def confirmed_at
      context.confirmed_at ||= DateTime.current
    end

    def guests
      @guests ||= SpreeCmCommissioner::Guest.where(id: guest_ids).index_by(&:id)
    end

    def create_check_in_for(guest_id)
      context.fail!(message: :guest_id_must_not_blank) if guest_id.blank?

      guest = guests[guest_id.to_i]
      context.fail!(message: :guest_not_found) if guest.blank?

      return guest.check_in if guest.check_in.present?

      event = guest.line_item.product.taxons.where(kind: :event).first.parent

      check_in = SpreeCmCommissioner::CheckIn.new(
        guest: guest,
        check_in_by: check_in_by,
        checkinable: event,
        confirmed_at: confirmed_at
      )

      return check_in if check_in.save

      context.fail!(message: :invalid, errors: check_in.errors.full_messages)
    end
  end
end
