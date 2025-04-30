module SpreeCmCommissioner
  module OrderImporter
    class MultiGuest < BaseInteractor
      delegate :params, :guest_token, :quantity, to: :context

      def call
        return context.fail!(message: 'variant_id_is_required') if params[:variant_id].blank?
        return context.fail!(message: 'email_or_phone_is_required') if params[:order_email].blank? && params[:order_phone_number].blank?

        context.order = construct_order
        context.fail!(message: context.order.errors.full_messages.to_sentence) unless context.order.save
      end

      def construct_order
        guest_params = params.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
        guest_params[:token] = guest_token if guest_token.present?

        Spree::Order.new(
          email: params[:order_email],
          phone_number: params[:order_phone_number],
          completed_at: Date.current,
          state: 'complete',
          payment_state: 'paid',
          line_items_attributes: [
            {
              quantity: quantity.to_i,
              variant_id: params[:variant_id],
              guests_attributes: [
                guest_params
              ]
            }
          ]
        )
      end
    end
  end
end
