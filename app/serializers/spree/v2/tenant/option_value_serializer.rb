module Spree
  module V2
    module Tenant
      class OptionValueSerializer < BaseSerializer
        attributes :name, :presentation, :position, :public_metadata

        belongs_to :option_type

        attribute :display_icon do |option_value|
          ActionController::Base.helpers.image_url(option_value.display_icon)
        rescue StandardError
          nil
        end
      end
    end
  end
end
