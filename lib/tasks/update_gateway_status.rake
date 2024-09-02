# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Execute Update Payment Gateway Status Job'
  task update_gateway_status: :environment do
    SpreeCmCommissioner::UpdatePaymentGatewayStatus.call
  end
end
