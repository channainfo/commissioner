module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        module IconSerializerDecorator
          def self.prepended(base)
            base.attributes :url
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Platform::IconSerializer.included_modules.include?(SpreeCmCommissioner::Api::V2::Platform::IconSerializerDecorator)
  Spree::Api::V2::Platform::IconSerializer.prepend SpreeCmCommissioner::Api::V2::Platform::IconSerializerDecorator
end
