# Custom replacement for Spree::Orders::FindCurrent with the following improvements:
# - Supports filtering by state (e.g., to retrieve only 'cart' or 'address' orders for the page cart)
# - Allows retrieving the order in any state (not just incomplete), which solves the issue of 404s after payment
module SpreeCmCommissioner
  module Orders
    class Find
      def execute(store:, user:, currency:, token: nil, state: nil)
        params = { store_id: store.id, currency: currency }
        params[:state] = state if state.present?

        return find_by_token(params, token) if token.present?
        return find_by_user(params, user) if user.present?

        nil
      end

      def find_by_token(params, token)
        params[:token] = token
        scope.find_by(params)
      end

      def find_by_user(params, user)
        params[:user_id] = user.id
        scope.order(created_at: :desc).find_by(params)
      end

      private

      def scope
        Spree::Order.not_archived.not_canceled
      end
    end
  end
end
