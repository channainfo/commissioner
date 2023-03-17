module SpreeCmCommissioner
  module Orders
    class FindByState < Spree::Orders::FindComplete
      attr_reader :user, :number, :token, :store, :state

      def initialize(user: nil, number: nil, token: nil, store: nil, state: nil)
        @state = state
        super(user: user, number: number, token: token, store: store)
      end

      private

      def scope
        user? ? user.orders.where(state: @state).includes(scope_includes) : Spree::Order.where(state: @state).includes(scope_includes)
      end
    end
  end
end
