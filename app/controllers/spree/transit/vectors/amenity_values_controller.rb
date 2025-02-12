module Spree
  module Transit
    module Vectors
      class AmenityValuesController < Spree::Transit::BaseController
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
          transit_vectors_amenity_values_url(options)
        end

        def kind
          @kind = 'vehicle_type'
        end
      end
    end
  end
end
