module Spree
  module Admin
    class ProductCommissionsController < Spree::Admin::ResourceController
      belongs_to 'spree/vendor', find_by: :slug

      helper_method :commission_for

      around_action :set_writing_role, only: %i[update_commissions update_default_commission]

      def update_commissions
        ActiveRecord::Base.transaction do
          params[:products]&.each do |id, attributes|
            product = collection.find(id)

            product.commission_rate = attributes[:commission_rate]
            product.save!
          end
        end

        flash[:success] = flash_message_for(@parent, :successfully_updated)
        redirect_to collection_url
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.record.errors.full_messages.join(', ')
        redirect_back fallback_location: collection_url
      end

      def update_default_commission
        attributes = params.require(:vendor).permit(:commission_rate)

        if @parent.update(attributes)
          flash[:success] = flash_message_for(@parent, :successfully_updated)
          redirect_to collection_url
        else
          flash[:error] = @parent.errors.full_messages.join(', ')
          redirect_back fallback_location: collection_url
        end
      end

      def collection_url(options = {})
        admin_vendor_product_commissions_url(options)
      end

      def commission_for(product)
        commission_rate = product.commission_rate || product.vendor&.commission_rate || 0
        product.price * commission_rate / 100
      end

      # override
      def collection_actions
        %i[index update_commissions update_default_commission]
      end

      # override
      def collection
        @collection ||= parent.products.order(:id)
      end

      # override
      def model_class
        Spree::Product
      end
    end
  end
end
