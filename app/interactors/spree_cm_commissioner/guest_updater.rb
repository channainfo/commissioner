module SpreeCmCommissioner
  class GuestUpdater < BaseInteractor
    def call
      guest = context.guest
      guest_params = context.guest_params
      template_guest_id = context.template_guest_id

      if template_guest_id.present?
        update_with_template_guest(guest, template_guest_id)
      else
        update_without_template_guest(guest, guest_params)
      end
    end

    private

    def update_with_template_guest(guest, template_guest_id)
      template_guest = SpreeCmCommissioner::TemplateGuest.find(template_guest_id)

      if guest.update(template_guest.attributes.except('id', 'created_at', 'updated_at', 'is_default', 'deleted_at'))
        duplicate_id_card(guest, template_guest) if template_guest.id_card.present?
      else
        context.fail!(message: guest.errors.full_messages.to_sentence)
      end
    end

    def update_without_template_guest(guest, guest_params)
      return if guest.update(guest_params)

      context.fail!(message: guest.errors.full_messages.to_sentence)
    end

    def duplicate_id_card(guest, template_guest)
      result = SpreeCmCommissioner::IdCardDuplicator.call(guest: guest, template_guest: template_guest)

      return if result.success?

      context.fail!(message: result.message)
    end
  end
end
