module Spree
  module Admin
    class GuestsController < Spree::Admin::ResourceController
      include OrderConcern
      helper SpreeCmCommissioner::Admin::GuestHelper

      before_action :load_order
      before_action :load_guest, only: %i[check_in uncheck_in]

      def model_class
        SpreeCmCommissioner::Guest
      end

      def collection_url
        spree.admin_order_guests_url(@order)
      end

      def object_name
        'spree_cm_commissioner_guest'
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
          format.js { render js: 'window.location.reload(true);' }
        end
      end

      def new
        @line_item = @order.line_items.find(params[:line_item_id])
        @kyc_fields = @line_item.kyc_fields
      end

      def edit
        @kyc_fields = @object.line_item.kyc_fields
        @check_in = @object.check_in
      end

      def check_in
        result = SpreeCmCommissioner::CheckInBulkCreator.call(
          check_ins_attributes: [{ guest_id: @guest.id }],
          check_in_by: spree_current_user
        )

        if result.success?
          flash[:success] = "Guest #{@guest.full_name} has been checked in."
        else
          flash[:error] = result.message.to_s.titleize
        end

        redirect_to collection_url
      end

      def uncheck_in
        result = SpreeCmCommissioner::CheckInDestroyer.call(
          guest_ids: [@guest.id],
          destroyed_by: spree_current_user
        )

        if result.success?
          flash[:success] = "Guest #{@guest.full_name} has been unchecked."
        else
          flash[:error] = result.message.to_s.titleize
        end

        redirect_to collection_url
      end

      private

      def permitted_resource_params
        params.require(object_name).permit(:first_name, :last_name, :gender, :dob, :occupation_id,
                                           :nationality_id, :age, :emergency_contact, :line_item_id,
                                           :seat_number, :phone_number
        )
      end

      def load_guest
        @guest = @order.guests.find(params[:id])
      end
    end
  end
end
