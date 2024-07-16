module Spree
  module Admin
    class S3PresignedUrlsController < ApplicationController
      # file_name, config, uuid
      def create
        presigned_url = SpreeCmCommissioner::S3PresignedUrlBuilder.call(
          bucket_name: 'input-production-cm',
          object_key: object_key
        )

        render json: {
          url: presigned_url.url,
          fields: presigned_url.fields
        }
      end

      private

      def object_key
        segment = Time.zone.now.strftime('%Y-%m')
        # Get the file extension
        ext = File.extname(params[:file_name])
        # Get the file name without the extension
        file_name = File.basename(params[:file_name], ext)

        # config = 'f24-p7-q3'
        config = params[:config]
        uuid = params[:uuid]

        new_file_name = "#{file_name}-#{uuid}-#{config}#{ext}"

        "medias/#{segment}/#{new_file_name}"
      end
    end
  end
end
