# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Ensure event id is present for guests.'
  task ensure_event_id_for_guests: :environment do
    SpreeCmCommissioner::EnsureEventIdForGuestsJob.perform_now
  end
end
