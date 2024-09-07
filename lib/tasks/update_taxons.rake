# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Update each Taxon'
  task update_taxons: :environment do
    Spree::Taxon.find_each(&:touch)
  end
end
