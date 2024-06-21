# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Ensure line item number is present.'
  task ensure_number_for_line_items: :environment do
    Spree::LineItem
      .where(number: nil)
      .find_each do |line_item|
      host = Spree::LineItem
      number = host.number_generator.generate_permalink(host)
      line_item.update_columns(number: number) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
