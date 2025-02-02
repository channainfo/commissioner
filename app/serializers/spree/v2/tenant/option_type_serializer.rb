module Spree
  module V2
    module Tenant
      class OptionTypeSerializer < BaseSerializer
        attributes :name, :presentation, :position, :public_metadata,
                   :kind, :attr_type, :promoted, :hidden

        has_many   :option_values
      end
    end
  end
end
