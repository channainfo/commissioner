module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        module UserSerializerDecorator
          def self.prepended(base)
            base.attributes :phone_number
            base.attribute :email_phone_number, &:email_phone_number
          end
        end
      end
    end
  end
  Spree::Api::V2::Platform::UserSerializer.prepend(SpreeCmCommissioner::Api::V2::Platform::UserSerializerDecorator)
end
