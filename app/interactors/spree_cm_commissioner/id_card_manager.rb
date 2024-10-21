module SpreeCmCommissioner
  class IdCardManager < BaseInteractor
    delegate :card_type, :front_image_url, :back_image_url, :guestable_id, to: :context

    def call
      if guest.id_card.blank? && front_image_url.present?
        create_guest_id_card
      elsif guest.id_card.present?
        update_guest_id_card
      else
        context.fail!(message: 'Image url can not be empty')
      end
    end

    def create_guest_id_card
      id_card = guest.build_id_card(card_type: card_type)

      manage_front_image(id_card)
      manage_back_image(id_card) if back_image_url.present?

      context.fail!(message: 'Failed to create Id card') unless context.success? && id_card.save
      context.result = guest.id_card
    end

    def update_guest_id_card
      manage_card_type(guest.id_card) if card_type.present?
      manage_front_image(guest.id_card) if front_image_url.present?
      manage_back_image(guest.id_card) if back_image_url.present?

      context.fail!(message: 'Failed to update Id card') unless context.success? && guest.id_card.save
      context.result = guest.id_card
    end

    def guest
      guestable
    end

    def manage_card_type(id_card)
      id_card.update(card_type: card_type)
    end

    def manage_front_image(id_card)
      context = SpreeCmCommissioner::IdCardImageUpdater.call(
        id_card: id_card,
        image_url: front_image_url,
        type: 'front_image'
      )

      context.fail!(message: 'Failed to update front image') unless context.success?
    end

    def manage_back_image(id_card)
      context = SpreeCmCommissioner::IdCardImageUpdater.call(
        id_card: id_card,
        image_url: back_image_url,
        type: 'back_image'
      )
      context.fail!(message: 'Failed to update back image') unless context.success?
    end

    def guestable
      context.fail!(message: 'Image url can not be empty')
    end
  end
end
