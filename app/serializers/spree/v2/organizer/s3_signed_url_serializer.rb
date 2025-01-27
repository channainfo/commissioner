module Spree
  module V2
    module Organizer
      class S3SignedUrlSerializer < BaseSerializer
        set_type :s3_signed_url
        attribute :host, :fields, :url
      end
    end
  end
end
