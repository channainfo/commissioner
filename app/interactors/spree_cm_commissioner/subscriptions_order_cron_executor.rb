module SpreeCmCommissioner
  class SubscriptionsOrderCronExecutor < BaseInteractor
    def call
      customers = SpreeCmCommissioner::Customer.where('active_subscriptions_count > ?', 0)
      customers.each do |customer|
        SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer)
      end
    end
  end
end
