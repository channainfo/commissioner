module SpreeCmCommissioner
  module V2
    module Storefront
      class EventOptionValueSerializer < BaseSerializer
        attributes :name, :presentation

        has_one :option_type, serializer: Spree::V2::Storefront::OptionTypeSerializer
      end
    end
  end
end
