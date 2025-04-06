module Spree
  module V2
    module Storefront
      module CartSerializerDecorator
        def self.prepended(base)
          base.attributes :phone_number, :intel_phone_number, :country_code, :request_state,
                          :channel

          base.attribute :qr_data do |order|
            order.qr_data if order.completed?
          end

          # override to return all payments instead of only valid_payments
          base.has_many :payments
        end
      end
    end
  end
end

Spree::V2::Storefront::CartSerializer.prepend Spree::V2::Storefront::CartSerializerDecorator
