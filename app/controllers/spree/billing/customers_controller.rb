module Spree
  module Billing
    class CustomersController < Spree::Billing::BaseController
      before_action :set_vendor, if: -> { member_action? }
      before_action :load_customer, if: -> { member_action? }
      before_action :load_bussinesses

      def scope
        if spree_current_user.has_spree_role?('admin')
          current_vendor.customers
        else
          current_vendor.customers.where(place_id: spree_current_user.place_ids)
        end
      end

      def collection
        return [] if current_vendor.blank?
        return @collection if defined?(@collection)

        @search = scope.ransack(params[:q])
        @collection = @search.result.includes(:subscriptions, :taxons).page(page).per(per_page)
      end

      def load_customer
        @customer = @object
      end

      def load_bussinesses
        @businesses = Spree::Taxonomy.businesses.taxons.where('depth > ? ', 1).order('parent_id ASC').uniq
      end

      # POST  /billing/customers/:customer_id/re_create_order
      # billing_customer_re_create_order_path
      def re_create_order
        today = Time.zone.today
        customer = model_class.find_by(id: params[:customer_id])
        result = SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer, today: today)

        if result.failure?
          flash[:error] = I18n.t('spree.billing.customers.re_create_order.fails', error: result.error)
        else
          flash[:success] = I18n.t('spree.billing.customers.re_create_order.success', success: result.success)
        end
        redirect_back(fallback_location: billing_customer_orders_path(customer))
      end

      # POST  /billing/customers/:customer_id/apply_promotion
      # billing_customer_apply_promotion_path
      def apply_promotion
        result = SpreeCmCommissioner::CustomerPromotionCreator.call(
          customer_id: params[:customer_id],
          reason: params[:reason],
          discount_amount: params[:discount_amount],
          store: current_store
        )

        if result.success?
          flash[:success] = I18n.t('spree.billing.customers.apply_promotion.success')
        else
          flash[:error] = I18n.t('spree.billing.customers.apply_promotion.fails', error: result.message)
        end

        redirect_back(fallback_location: billing_customer_orders_path(params[:customer_id]))
      end

      # delete /billing/customers/:customer_id/delete_promotion/:id
      # billing_customer_delete_promotion_url
      def delete_promotion
        customer = model_class.find(params[:customer_id])
        promotion = Spree::Promotion.find_by(code: customer.number)
        if promotion.destroy
          flash[:success] = I18n.t('spree.billing.customers.delete_promotion.success')
        else
          flash[:error] = I18n.t('spree.billing.customers.delete_promotion.fails', error: result.message)
        end

        redirect_back(fallback_location: billing_customer_orders_path(params[:customer_id]))
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::Customer
      end

      def object_name
        'spree_cm_commissioner_customer'
      end

      # @overrided
      def collection_url(options = {})
        billing_customers_url(options)
      end

      def location_after_save
        if permitted_resource_params.key?(:bill_address_attributes) && permitted_resource_params.key?(:ship_address_attributes)
          billing_customer_addresses_url(@customer)
        else
          edit_billing_customer_url(@customer)
        end
      end

      def set_vendor
        permitted_resource_params[:vendor] = current_vendor
      end
    end
  end
end
