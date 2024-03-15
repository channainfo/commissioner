module Spree
  module Admin
    class GuestsController < Spree::Admin::ResourceController
      include OrderConcern
      helper SpreeCmCommissioner::Admin::GuestHelper

      before_action :load_order

      def model_class
        SpreeCmCommissioner::Guest
      end

      def collection_url
        spree.admin_order_guests_url(@order)
      end

      def object_name
        'spree_cm_commissioner_guest'
      end

      def new
        @line_item = @order.line_items.find(params[:line_item_id])
        @kyc_fields = @line_item.kyc_fields
      end

      def add_guest
        SpreeCmCommissioner::Cart::AddGuest.call(order: @order, line_item: @order.line_items.find(params[:line_item_id]))

        redirect_to location_after_save
      end

      def remove_guest
        @line_item = @order.line_items.find(params[:line_item_id])

        SpreeCmCommissioner::Cart::RemoveGuest.call(order: @order, line_item: @line_item, guest_id: params[:guest_id])

        respond_to do |format|
          format.html { redirect_to location_after_destroy }
          format.js   { render_js_for_destroy }
        end
      end

      def edit
        @kyc_fields = @object.line_item.kyc_fields
      end

      def create
        guest = SpreeCmCommissioner::Guest.new(permitted_resource_params)
        if guest.save
          redirect_to collection_url
        else
          render :new
        end
      end

      def permitted_resource_params
        params.require(object_name).permit(:first_name, :last_name, :gender, :dob, :occupation_id, :nationality_id, :line_item_id)
      end
    end
  end
end
