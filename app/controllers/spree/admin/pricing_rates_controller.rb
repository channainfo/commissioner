module Spree
  module Admin
    class PricingRatesController < ResourceController
      skip_before_action :load_resource

      before_action :load_parent
      before_action :load_object, if: :member_action?

      def load_parent
        @product = Spree::Product.find_by!(slug: params[:product_id])

        return redirect_to admin_product_variants_url(@product) if @product.variants.empty?
        return redirect_to collection_url(variant_id: @product.variants.first&.id) if params[:variant_id].blank?
        return redirect_to collection_url(currency: Spree::Store.default.default_currency) if params[:currency].blank?

        @variant = Spree::Variant.find(params[:variant_id])
      end

      def load_object
        if new_actions.include?(action)
          @object = @variant.pricing_rates.new
        elsif params[:id]
          @object = @variant.pricing_rates.find(params[:id])
        end
      end

      def index
        @pricing_rates = @variant.pricing_rates
        respond_with(@pricing_rates) do |format|
          format.html
          format.js { render partial: 'pricing_rates' }
        end
      end

      def create
        @object.attributes = permitted_resource_params
        if @object.save
          flash[:success] = flash_message_for(@object, :successfully_created)
          redirect_to edit_object_url(@object)
        else
          render action: :new, status: :unprocessable_entity
        end
      end

      def update_prices
        params[:pricing_rates]&.each do |rate_params|
          pricing_rate = @variant.pricing_rates.find(rate_params[:id])
          price = pricing_rate.price_in(params[:currency])

          price.price = rate_params[:price].presence
          price.save! if price.changed?
        end

        # update default rate
        price = @variant.price_in(params[:currency])
        price.price = params[:default_rate_price].presence
        price.save! if price.changed?

        flash[:success] = Spree.t('notice_messages.prices_saved')
        redirect_to collection_url
      end

      # override
      def default_url_options
        super.merge(
          product_id: params[:product_id],
          variant_id: params[:variant_id],
          currency: params[:currency]
        )
      end

      # override
      def model_class
        SpreeCmCommissioner::PricingRate
      end

      # override
      def object_name
        'spree_cm_commissioner_pricing_rate'
      end

      # override
      def collection_url(options = {})
        admin_product_pricing_rates_url(options)
      end

      # override
      def new_object_url(options = {})
        new_admin_product_pricing_rate_url(options)
      end

      # override
      def edit_object_url(object, options = {})
        edit_admin_product_pricing_rate_url(@product, object, options)
      end

      # override
      def object_url(object, options = {})
        admin_product_pricing_rate_url(@product, object, options)
      end
    end
  end
end
