module SpreeCmCommissioner
  class UpdateUserCartItemCountHandler < BaseInteractor
    delegate :order, to: :context

    def call
      validate_order!
      validate_user!

      handle_updating_cart_item_count!
      assign_context_variable
    end

    private

    def assign_context_variable
      context.order = order
      context[:current_cart?] = current_cart?
    end

    def validate_user!
      context.fail!(message: 'User cannot be nil!') if user.nil?
    end

    def validate_order!
      context.fail!(message: 'Order cannot be nil!') if order.nil?
    end

    def user
      @user ||= order.user
    end

    def handle_updating_cart_item_count!
      return reset_user_cart_item_count! if order.completed?

      update_user_cart_item_count!
    end

    def validate_current_cart!
      context.fail!(message: "The order is not the user's current cart!") unless current_cart?
    end

    def update_user_cart_item_count!
      validate_current_cart!

      user.update(cart_item_count: order.item_count)
    end

    def reset_user_cart_item_count!
      user.update(cart_item_count: 0)
    end

    def current_cart?
      order == user_current_cart
    end

    def user_current_cart
      @user_current_cart ||= Spree::Api::Dependencies.storefront_current_order_finder.constantize.new.execute(
        store: order.store,
        user: order.user,
        user_id: order.user_id,
        currency: order.currency
      )
    end
  end
end
