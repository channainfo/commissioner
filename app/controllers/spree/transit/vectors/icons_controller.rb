module Spree
  module Transit
    module Vectors
      class IconsController < Spree::Transit::BaseController
        # @overrided
        def collection
          @collection ||= searcher.page(params[:page]).per(params[:per_page])
        end

        def model_class
          SpreeCmCommissioner::VectorIcon
        end

        private

        def searcher
          model_class.search(
            path_prefix: params[:path_prefix],
            extension: params[:extension],
            query: params[:query]
          )
        end
      end
    end
  end
end
