module SpreeCmCommissioner
  class UserOrderTransferHandler < BaseInteractor
    delegate :user, :order_numbers, to: :context

    def call
      orders = find_annonymous_orders

      if orders.empty?
        context.fail!(message: 'No orders found.')
      else
        process_orders(orders)
        handle_results
      end
    end

    private

    def find_annonymous_orders
      orders = Spree::Order.where(user_id: nil).where(number: order_numbers)
      if user.email && user.intel_phone_number
        orders = orders.where(['email = ? OR intel_phone_number = ?', user.email, user.intel_phone_number])
      elsif user.email
        orders = orders.where(email: user.email)
      elsif user.intel_phone_number
        orders = orders.where(intel_phone_number: user.intel_phone_number)
      end
      orders
    end

    def process_orders(orders)
      @successful_transfers = []
      @failed_transfers = []

      orders.each do |order|
        if transfer_order_to_user(order)
          @successful_transfers << order
        else
          @failed_transfers << order
        end
      end
    end

    def transfer_order_to_user(order)
      order.update(user_id: user.id)
    end

    def handle_results
      if @successful_transfers.size == order_numbers.size
        context.success = true
        context.successful_orders = @successful_transfers
      else
        context.fail!(message: "Error transferring Orders: #{@failed_transfers.map(&:number).join(', ')}")
      end
    end
  end
end
