module Spree
  module Admin
    module OptionTypesControllerDecorator
      def collection_finder
        @collection_finder = params[:kind].present? ? Spree::OptionType.where(kind: params[:kind]) : Spree::OptionType.all
      end

      def collection
        @search = collection_finder.ransack(params[:q])
        @collection = @search.result
      end
    end
  end
end

Spree::Admin::OptionTypesController.prepend(Spree::Admin::OptionTypesControllerDecorator)
