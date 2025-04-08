module SpreeCmCommissioner
  module OrderConcern
    # override
    def spree_current_order
      @spree_current_order ||= find_spree_current_order
      return nil if @spree_current_order.blank?

      # Spree doesn't validate this by default (might be a bug).
      # Temporary fix to ensure the order's user ID matches the logged-in user.
      if @spree_current_order.user_id.present? && spree_current_user.present? && @spree_current_order.user_id != spree_current_user.id
        raise CanCan::AccessDenied
      end

      @spree_current_order
    end

    # override
    def find_spree_current_order
      SpreeCmCommissioner::Orders::Find.new.execute(
        store: current_store,
        user: spree_current_user,
        currency: current_currency,
        token: order_token,
        state: params[:state]
      )
    end
  end
end
