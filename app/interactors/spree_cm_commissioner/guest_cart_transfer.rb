module SpreeCmCommissioner
  class GuestCartTransfer < BaseInteractor
    delegate :store, :currency, :user, :guest_token, :guest_id, :merge_type, to: :context

    MERGE_TYPES = {
      merge: 'merge',
      replace: 'replace'
    }.freeze

    # Params required:
    # {
    #   store,
    #   currency,
    #   user,
    #   guest_token,
    #   guest_id,
    #   merge_type
    # }
    def call
      validate_merge_type!
      validate_guest_presence!
      validate_guest_cart_presence!

      ActiveRecord::Base.transaction do
        transfer_guest_cart_to_user!
      end
    end

    private

    def validate_merge_type!
      context.fail!(message: "Invalid merge type: #{merge_type}") unless MERGE_TYPES.values.include?(merge_type)
    end

    def validate_guest_presence!
      context.fail!(message: 'Guest is invalid!') if guest.nil?
    end

    def validate_guest_cart_presence!
      context.fail!(message: 'Guest has no cart to transfer!') if guest_cart.nil?
    end

    def transfer_guest_cart_to_user!
      return handle_replace_cart! if merge_type == 'replace'

      handle_merge_cart!
    end

    def handle_replace_cart!
      # Must call delete_user_cart! first or it deletes the transfering cart
      delete_user_cart!
      update_guest_cart_to_user!
    end

    def delete_user_cart!
      user_cart&.destroy!
    end

    def update_guest_cart_to_user!
      guest_cart.update!(user: user)

      # To prevent these being deleted when the guest user & cart are
      # destroyed, we need to reload the guest record:
      guest.reload
    end

    def handle_merge_cart!
      return merge_cart! if user_cart.present?

      update_guest_cart_to_user!
    end

    def merge_cart!
      guest_cart.line_items.reload.each do |guest_item|
        transfer_cart_item(guest_item)
      end

      # Clear or delete the guest cart after transfer
      guest_cart.reload.destroy!
    end

    def transfer_cart_item(guest_item)
      existing_item = user_items[guest_item.variant_id]

      if existing_item
        existing_item.update!(quantity: existing_item.quantity + guest_item.quantity)
      else
        guest_item.update!(order: user_cart)
      end
    end

    def user_items
      @user_items ||= user_cart.line_items.index_by(&:variant_id)
    end

    def guest
      @guest ||= find_guest_user
    end

    def find_guest_user
      user = Spree::User.find_by(id: guest_id)
      return nil unless user&.guest?

      begin
        user if SpreeCmCommissioner::UserJwtToken.decode(guest_token, user.secure_token)
      rescue JWT::DecodeError
        nil
      end
    end

    def guest_cart
      @guest_cart ||= find_current_order(guest)
    end

    def user_cart
      @user_cart ||= find_current_order(user)
    end

    def find_current_order(user)
      Spree::Api::Dependencies.storefront_current_order_finder.constantize.new.execute(
        store: store,
        user: user,
        user_id: user.id,
        currency: currency
      )
    end
  end
end
