module SpreeCmCommissioner
  class SubscriptionsOrderCronExecutor < BaseInteractor
    def call
      today = Time.zone.today
      customers = SpreeCmCommissioner::Customer.where('active_subscriptions_count > ?', 0)
      customers.each do |customer|
        SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer, today: today)
      end
    end
  end
end
