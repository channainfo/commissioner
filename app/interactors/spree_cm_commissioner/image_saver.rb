module SpreeCmCommissioner
  class ImageSaver < BaseInteractor
    def call
      presigned_url = SpreeCmCommissioner::S3UrlGenerator.s3_presigned_url(context.url)

      response = Faraday.get(presigned_url)

      if response.success?
        io = StringIO.new(response.body)
        filename = File.basename(context.url)

        image = find_or_initialize_image
        image.attachment.attach(io: io, filename: filename)

        if image.save
          context.result = image
        else
          context.fail!(message: image.errors.full_messages.join(','))
        end
      else
        context.fail!(message: I18n.t('s3.image.upload.fail'))
      end
    rescue StandardError => e
      context.fail!(message: e.message)
    end

    private

    def find_or_initialize_image
      if context.id.present?
        Spree::Image.find_by(id: context.id) || context.fail!(message: I18n.t('s3.image.upload.not_found'))
      else
        Spree::Image.new(viewable_type: context.viewable_type, viewable_id: context.viewable_id)
      end
    end
  end
end
