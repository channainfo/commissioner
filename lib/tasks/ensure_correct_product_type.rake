# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Ensure product_type in variants, line_items, inventory_items are correct with product'
  task ensure_correct_product_type: :environment do
    SpreeCmCommissioner::EnsureCorrectProductTypeJob.perform_now
  end
end
