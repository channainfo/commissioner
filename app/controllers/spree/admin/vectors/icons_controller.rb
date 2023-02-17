module Spree
  module Admin
    module Vectors
      class IconsController < Spree::Admin::ResourceController
        include SpreeCmCommissioner::IconSetConcern

        # @overrided
        def collection
          @collection ||= [
            backend_icon_objects,
            commissioner_icon_objects
          ]
        end

        def model_class
          SpreeCmCommissioner::VectorIcon
        end
      end
    end
  end
end
