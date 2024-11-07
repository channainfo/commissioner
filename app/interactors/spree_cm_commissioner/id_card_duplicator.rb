module SpreeCmCommissioner
  class IdCardDuplicator < BaseInteractor
    def call
      guest = context.guest
      template_guest = context.template_guest

      if template_guest.id_card.present?
        # Duplicate ID card and associated images
        new_id_card = template_guest.id_card.dup
        new_id_card.id_cardable = guest

        if duplicate_image(template_guest.id_card.front_image, new_id_card, :front_image) &&
            duplicate_image(template_guest.id_card.back_image, new_id_card, :back_image)

          new_id_card.save!
          guest.id_card = new_id_card
          guest.save!

          context.message = 'ID card duplicated successfully'
        else
          context.fail!(message: 'Failed to duplicate one or more images')
        end
      else
        context.fail!(message: 'Template guest does not have an ID card to duplicate')
      end
    end

    private

    def duplicate_image(image, new_id_card, image_type)
      return true if image.blank?

      new_image = image.dup
      new_image.viewable = new_id_card
      new_image.attachment.attach(
        io: StringIO.new(image.attachment.download),
        filename: image.attachment.filename.to_s,
        content_type: image.attachment.content_type
      )

      if new_image.save
        new_image
      else
        context.fail!(message: "Failed to duplicate #{image_type} image")
        false
      end
    end
  end
end
