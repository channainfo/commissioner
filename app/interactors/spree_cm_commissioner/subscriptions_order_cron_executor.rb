module SpreeCmCommissioner
  class SubscriptionsOrderCronExecutor < BaseInteractor
    def call
      today = Time.zone.today
      customers = SpreeCmCommissioner::Customer.where('active_subscriptions_count > ? and status = ?', 0, 0)
      customers.each do |customer|
        SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer, today: today)
      end
    end
  end
end
