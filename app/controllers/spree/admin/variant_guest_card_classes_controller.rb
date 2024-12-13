module Spree
  module Admin
    class VariantGuestCardClassesController < Spree::Admin::ResourceController
      before_action :load_product
      before_action :load_taxon, only: :index
      before_action :load_guest_card_classes, only: :index

      def create
        variant_params = guest_card_class_params

        @product.variants.each do |variant|
          guest_card_class_id = variant_params[variant.id.to_s]

          next if guest_card_class_id.blank?

          variant_guest_card_class = model_class.find_or_initialize_by(variant_id: variant.id)
          variant_guest_card_class.guest_card_class_id = guest_card_class_id

          variant_guest_card_class.save if variant_guest_card_class.changed?
        end

        flash[:success] = flash_message_for(@object, :successfully_created)
        redirect_to collection_url(@product)
      end

      private

      def guest_card_class_params
        params.require(:variant_guest_card_class).permit(@product.variants.map { |variant| variant.id.to_s })
      end

      def load_product
        @product = Spree::Product.find_by(slug: params[:product_id])
      end

      def load_guest_card_classes
        @guest_card_classes = @taxon ? @taxon.guest_card_classes : []
      end

      def load_taxon
        @taxon = @product.taxons.first&.parent
        @taxonomy = @taxon&.taxonomy
      end

      def model_class
        SpreeCmCommissioner::VariantGuestCardClass
      end

      def object_name
        'spree_cm_commissioner_variant_guest_card_class'
      end

      def collection_url(product)
        admin_product_variant_guest_card_classes_url(product)
      end
    end
  end
end
