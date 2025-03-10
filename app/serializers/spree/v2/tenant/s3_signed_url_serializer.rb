module Spree
  module V2
    module Tenant
      class S3SignedUrlSerializer < BaseSerializer
        attribute :host, :fields, :url
      end
    end
  end
end
