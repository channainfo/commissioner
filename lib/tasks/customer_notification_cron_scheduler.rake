# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Execute Customer Notification Cron'
  task customer_notification_cron_scheduler: :environment do
    SpreeCmCommissioner::CustomerNotificationCronJob.perform_now
  end
end
