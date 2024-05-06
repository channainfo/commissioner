module Spree
  module Admin
    class PricingRulesController < ResourceController
      skip_before_action :load_resource

      before_action :load_parent
      before_action :load_object, if: :member_action?

      def load_parent
        @product = Spree::Product.find_by!(slug: params[:product_id])

        if params[:pricing_rate_id].present?
          @pricing_ruleable = SpreeCmCommissioner::PricingRate.find(params[:pricing_rate_id])
        elsif params[:pricing_model_id].present?
          @pricing_ruleable = SpreeCmCommissioner::PricingModel.find(params[:pricing_model_id])
        end

        raise ActiveRecord::RecordNotFound if @pricing_ruleable.nil?
      end

      def load_object
        if new_actions.include?(action)
          @object = @pricing_ruleable.pricing_rules.new
        elsif params[:id]
          @object = @pricing_ruleable.pricing_rules.find(params[:id])
        end
      end

      def index
        @pricing_rules = @pricing_ruleable.pricing_rules.sort_by { |rule| @pricing_ruleable.default_pricing_rules.index(rule.type) || 0 }
      end

      def update
        if @object.update(permitted_resource_params)
          flash[:success] = flash_message_for(@object, :successfully_updated)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to collection_url
      end

      # override
      def default_url_options
        super.merge(
          pricing_rate_id: params[:pricing_rate_id],
          pricing_model_id: params[:pricing_model_id],
          product_id: params[:product_id],
          variant_id: params[:variant_id],
          currency: params[:currency]
        )
      end

      # override
      def model_class
        SpreeCmCommissioner::PricingRule
      end

      # override
      def object_name
        'spree_cm_commissioner_pricing_rule'
      end

      # override
      def collection_url(options = {})
        admin_product_pricing_rules_url(options)
      end

      # override
      def new_object_url(options = {})
        new_admin_product_pricing_rule_url(options)
      end

      # override
      def edit_object_url(object, options = {})
        edit_admin_product_pricing_rule_url(object, options)
      end

      # override
      def object_url(object, options = {})
        admin_product_pricing_rule_url(object, options)
      end
    end
  end
end
