module Spree
  module V2
    module Tenant
      class ProductPropertySerializer < BaseSerializer
        attribute :value, :filter_param, :show_property, :position

        attribute :name, &:property_name

        attribute :description, &:property_presentation
      end
    end
  end
end
