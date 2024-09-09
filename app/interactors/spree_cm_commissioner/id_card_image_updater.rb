module SpreeCmCommissioner
  class IdCardImageUpdater < BaseInteractor
    delegate :id_card, :type, to: :context

    def call
      presigned_url = SpreeCmCommissioner::S3UrlGenerator.s3_presigned_url(context.image_url)

      response = Faraday.get(presigned_url)

      if response.success?
        id_card = context.id_card
        io = StringIO.new(response.body)
        filename = File.basename(context.image_url)

        id_card_image = id_card_image(id_card)
        id_card_image.attachment.attach(io: io, filename: filename)

        if id_card_image.save
          context.result = id_card
        else
          context.fail!(message: id_card_image.errors.full_messages.join(','))
        end
      end
    rescue StandardError => e
      context.fail!(message: "Error fetching the remote image: #{e.message}")
    end

    def id_card_image(id_card)
      case type
      when 'front_image'
        id_card.front_image || SpreeCmCommissioner::FrontImage.new(viewable: id_card)
      when 'back_image'
        id_card.back_image || SpreeCmCommissioner::BackImage.new(viewable: id_card)
      end
    end
  end
end
