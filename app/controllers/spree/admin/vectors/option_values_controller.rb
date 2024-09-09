module Spree
  module Admin
    module Vectors
      class OptionValuesController < Spree::Admin::ResourceController
        skip_before_action :load_resource, only: :update
        before_action :load_object, only: :update

        def load_object
          option_value_id = params['option-value-id']
          @object = Spree::OptionValue.find(option_value_id)
        end

        # @overrided
        def collection
          @vector_icons = SpreeCmCommissioner::VectorIcon.all
          @collection ||= Spree::OptionType.where(kind: kind)
        end

        # @overrided
        def model_class
          Spree::OptionValue
        end

        # @overrided
        def object_name
          'option_value'
        end

        # @overrided
        def collection_url(options = { kind: kind })
          admin_vectors_option_values_url(options)
        end

        def kind
          @kind = params[:kind] || 'variant'
        end
      end
    end
  end
end
