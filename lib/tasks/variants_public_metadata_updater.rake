# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Update variant metadata eg. public_metadata[:options]'
  task variants_public_metadata_updater: :environment do
    SpreeCmCommissioner::VariantsPublicMetadataUpdaterJob.perform_now
  end
end
