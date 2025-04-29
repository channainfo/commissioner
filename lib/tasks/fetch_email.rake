# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Fetch email from firebase'
  task fetch_email: :environment do
    SpreeCmCommissioner::FirebaseEmailFetcherJob.perform_now
  end
end
