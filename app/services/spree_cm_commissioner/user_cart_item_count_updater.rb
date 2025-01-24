module SpreeCmCommissioner
  class UserCartItemCountUpdater
    def call(order:)
      context = SpreeCmCommissioner::UpdateUserCartItemCountHandler.call(order: order)

      return unless context.success? & context.current_cart?

      SpreeCmCommissioner::UserCartItemCountJob.perform_later(order.id)
    end
  end
end
