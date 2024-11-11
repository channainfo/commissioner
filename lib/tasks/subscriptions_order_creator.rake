namespace :spree_cm_commissioner do
  desc 'Execute Subscription Order Creator Cron'
  task billing_invoice_recurring: :environment do
    SpreeCmCommissioner::SubscriptionOrderExecutorJob.perform_now
  end
end
