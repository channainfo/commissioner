module Spree
  module Admin
    class GuestQrCodesController < Spree::Admin::ResourceController
      before_action :load_variant

      def index
        @guests ||= guests_by_variant.page(params[:page]).per(params[:per_page])
        @total_guests_count ||= @guests.total_count
        @index_number = ((@guests.current_page - 1) * @guests.limit_value) + 1
      end

      def model_class
        SpreeCmCommissioner::Guest
      end

      def object_name
        'spree_cm_commissioner_guest'
      end

      private

      def load_variant
        @variant ||= Spree::Variant.find(params[:variant_id])
      end

      def guests_by_variant
        model_class.complete
                   .joins(line_item: { order: :variants })
                   .includes(line_item: { order: :variants })
                   .where(spree_variants: { id: params[:variant_id] })
                   .distinct
      end
    end
  end
end
