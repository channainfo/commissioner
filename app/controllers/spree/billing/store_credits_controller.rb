module Spree
  module Billing
    class StoreCreditError < StandardError; end

    class StoreCreditsController < Spree::Billing::BaseController
      before_action :load_user
      before_action :load_options
      before_action :load_categories, only: %i[new edit]
      before_action :load_store_credit, only: %i[new edit update]
      before_action :ensure_unused_store_credit, only: [:update]

      def index
        @store_credits = @user.store_credits.for_store(current_store).includes(:category).reverse_order
      end

      def create
        @store_credit = @user.store_credits.build(
          permitted_store_credit_params.merge(
            created_by: try_spree_current_user,
            action_originator: try_spree_current_user,
            store: current_store,
            currency: current_store.default_currency,
            category: Spree::StoreCreditCategory.where(name: 'Default').first
          )
        )

        @duration = params[:store_credit][:duration].to_i
        @store_credit.memo = params[:store_credit][:description]
        @store_credit.amount = total_amount
        if @store_credit.save
          SpreeCmCommissioner::SubscriptionsPrepaidOrderCreator.call(customer: @customer, store_credit: @store_credit, duration: @duration)
          flash[:success] = flash_message_for(@store_credit, :successfully_created)
          redirect_to spree.billing_customer_store_credits_path(@customer)
        else
          load_categories
          flash[:error] = Spree.t('store_credit.errors.unable_to_create')
          render :new, status: :unprocessable_entity
        end
      end

      def update
        @store_credit.assign_attributes(permitted_store_credit_params)
        @store_credit.created_by = try_spree_current_user

        if @store_credit.save
          flash[:success] = flash_message_for(@store_credit, :successfully_updated)
          redirect_to spree.billing_customer_store_credits_path(@customer)
        else
          load_categories
          flash[:error] = Spree.t('store_credit.errors.unable_to_update')
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @store_credit = @user.store_credits.for_store(current_store).find(params[:id])
        ensure_unused_store_credit

        if @store_credit.destroy
          flash[:success] = flash_message_for(@store_credit, :successfully_removed)
          respond_with(@store_credit) do |format|
            format.html { redirect_to spree.billing_customer_store_credits_path(@customer) }
            format.js { render_js_for_destroy }
          end
        else
          render plain: Spree.t('store_credit.errors.unable_to_delete'), status: :unprocessable_entity
        end
      end

      protected

      def total_amount
        @subscriptions.map(&:total_price).sum * @duration
      end

      def load_options
        @subscriptions = @customer.subscriptions
      end

      def permitted_store_credit_params
        params.require(:store_credit).permit(permitted_store_credit_attributes)
      end

      def collection_url(options = {})
        billing_customer_store_credits_url(@customer, options)
      end

      def load_user
        @customer = SpreeCmCommissioner::Customer.find(params[:customer_id])
        @user = @customer.user

        return if @user

        flash[:error] = Spree.t(:user_not_found)
        redirect_to spree.billing_customer_path(@customer)
      end

      def load_categories
        @credit_categories = Spree::StoreCreditCategory.order(:name)
      end

      def load_store_credit
        @store_credit = scope.find_by(id: params[:id]) || scope.new
      end

      def scope
        current_store.store_credits
      end

      def ensure_unused_store_credit
        return if @store_credit.amount_used.zero?

        raise StoreCreditError, Spree.t('store_credit.errors.cannot_change_used_store_credit')
      end
    end
  end
end
