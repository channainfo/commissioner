# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Remove duplicate device tokens.'
  task remove_duplicate_device_tokens: :environment do
    SpreeCmCommissioner::UniqueDeviceTokenCronJob.perform_now
  end
end
