module SpreeCmCommissioner
  module V2
    module Storefront
      class EventVariantSerializer < BaseSerializer
        has_many :option_values, serializer: SpreeCmCommissioner::V2::Storefront::EventOptionValueSerializer
      end
    end
  end
end
