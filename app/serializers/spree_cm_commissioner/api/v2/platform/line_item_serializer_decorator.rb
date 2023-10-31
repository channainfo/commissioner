module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        module LineItemSerializerDecorator
          def self.prepended(base)
            base.attributes :options_text

            base.has_one :vendor
          end
        end
      end
    end
  end
end

Spree::Api::V2::Platform::LineItemSerializer.prepend SpreeCmCommissioner::Api::V2::Platform::LineItemSerializerDecorator
