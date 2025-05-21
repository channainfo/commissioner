# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Ensure event for product variant line items.'
  task ensure_event_for_product_line_item_guests: :environment do
    SpreeCmCommissioner::EnsureEventForProductVariantLineItemsJob.perform_now
  end
end
