module SpreeCmCommissioner
  class CheckInBulkCreator < BaseInteractor
    delegate :check_ins_attributes, :check_in_by, to: :context

    def call
      context.fail!(message: :guest_ids_must_not_blank) if check_ins_attributes.blank?

      ActiveRecord::Base.transaction do
        context.check_ins = check_ins_attributes.map do |check_in_attributes|
          create_check_in_for(check_in_attributes)
        end
      end
    end

    private

    def confirmed_at
      context.confirmed_at ||= DateTime.current
    end

    def guest_ids
      context.guest_ids ||= check_ins_attributes.pluck(:guest_id)
    end

    def guests
      @guests ||= SpreeCmCommissioner::Guest.where(id: guest_ids).index_by(&:id)
    end

    def create_check_in_for(check_in_attributes)
      context.fail!(message: :guest_id_must_not_blank) if check_in_attributes[:guest_id].blank?

      guest = guests[check_in_attributes[:guest_id]]

      return context.fail!(message: :guest_not_found) if guest.blank?
      return context.fail!(message: :already_check_in) if guest.check_in.present?

      update_guest_data(guest, check_in_attributes) if guest_data_present?(check_in_attributes)

      check_in = SpreeCmCommissioner::CheckIn.new(
        guest: guest,
        check_in_by: check_in_by,
        checkinable: guest.event,
        confirmed_at: check_in_attributes[:confirmed_at] || confirmed_at
      )

      if check_in.save
        guest.state_changes.create!(
          user: check_in_by,
          previous_state: 'unchecked_in',
          next_state: 'checked_in',
          name: 'guest'
        )
        return check_in
      end

      context.fail!(message: :invalid, errors: check_in.errors.full_messages)
    end

    def guest_data_present?(check_in_attributes)
      check_in_attributes[:guest_attributes].present?
    end

    def update_guest_data(guest, check_in_attributes)
      guest_data = check_in_attributes[:guest_attributes]

      return if guest.update(guest_data)

      context.fail!(message: :invalid_guest_data, errors: guest.errors.full_messages)
    end
  end
end
