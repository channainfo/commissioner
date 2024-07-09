module SpreeCmCommissioner
  module Media
    class SignedUrlGenerator < Signer
      delegate :s3_object_key, :expiration_in_second, to: :context

      # s3_object_key: medias/dash/cohesion/cohesion.mpd
      def call
        sign
      end

      def sign
        context.result = signer.signed_url(url, expires: expiration_time)
      end
    end
  end
end
