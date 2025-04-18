FactoryBot.define do
  factory :cm_subscription, class: SpreeCmCommissioner::Subscription do
    start_date { '2022-12-25'.to_date }
    customer { create(:cm_customer) }

    transient do
      price { 30.0 }
      month { 1 }
      due_date { 5 }
      payment_option { 'pre-paid' }
    end

    before :create do |subscription, evaluator|
      subscription.variant ||= create(
        :cm_subscribable_product,
        vendor: subscription.customer.vendor,
        price: evaluator.price,
        month: evaluator.month,
        due_date: evaluator.due_date,
        payment_option: evaluator.payment_option
      ).variants.last
    end
  end
end
