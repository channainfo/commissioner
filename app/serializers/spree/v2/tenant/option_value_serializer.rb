module Spree
  module V2
    module Tenant
      class OptionValueSerializer < BaseSerializer
        attributes :name, :presentation, :position, :public_metadata

        attribute :display_icon do |option_value|
          ActionController::Base.helpers.image_url(option_value.display_icon)
        rescue StandardError
          nil
        end

        belongs_to :option_type, serializer: Spree::V2::Tenant::OptionTypeSerializer
      end
    end
  end
end
