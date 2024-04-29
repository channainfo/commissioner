module SpreeCmCommissioner
  class ReviewImageCreator < BaseInteractor
    def call
      presigned_url = SpreeCmCommissioner::S3UrlGenerator.s3_presigned_url(context.url)
      response = Faraday.get(presigned_url)

      if response.success?
        review = context.review
        io = StringIO.new(response.body)
        filename = File.basename(context.url)

        review_image = SpreeCmCommissioner::ReviewImage.new(viewable: review)
        review_image.attachment.attach(io: io, filename: filename)

        if review_image.save
          context.result = review_image

        else
          context.fail!(message: review_image.errors.full_messages.join(','))
        end
      end
    rescue StandardError => e
      context.fail!(message: "Error fetching the remote image: #{e.message}")
    end
  end
end
