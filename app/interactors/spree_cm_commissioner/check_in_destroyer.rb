module SpreeCmCommissioner
  class CheckInDestroyer < BaseInteractor
    delegate :guest_ids, :destroyed_by, to: :context

    def call
      context.fail!(message: :guest_ids_must_not_blank) if guest_ids.blank?

      ActiveRecord::Base.transaction do
        context.check_ins = guest_ids.map do |guest_id|
          destroy_check_in_for(guest_id)
        end.compact
      end
    end

    private

    def guests
      @guests ||= SpreeCmCommissioner::Guest.where(id: guest_ids).index_by(&:id)
    end

    def destroy_check_in_for(guest_id)
      context.fail!(message: :guest_id_must_not_blank) if guest_id.blank?

      guest = guests[guest_id.to_i]
      context.fail!(message: :guest_not_found) if guest.blank?

      return nil if guest.check_in.blank?

      check_in = guest.check_in
      if check_in.destroy
        guest.state_changes.create!(
          user: destroyed_by,
          previous_state: 'checked_in',
          next_state: 'unchecked_in',
          name: 'guest'
        )
        check_in
      else
        context.fail!(message: :invalid, errors: check_in.errors.full_messages)
      end
    end
  end
end
