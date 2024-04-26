module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        module DigitalSerializerDecorator
          def self.prepended(base)
            base.attributes :url
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Platform::DigitalSerializer.included_modules.include?(SpreeCmCommissioner::Api::V2::Platform::DigitalSerializerDecorator)
  Spree::Api::V2::Platform::DigitalSerializer.prepend SpreeCmCommissioner::Api::V2::Platform::DigitalSerializerDecorator
end
