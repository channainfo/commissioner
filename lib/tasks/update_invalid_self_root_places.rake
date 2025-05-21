namespace :spree_cm_commissioner do
  desc 'Update invalid self-root places...'
  task update_invalid_self_root_places: :environment do
    SpreeCmCommissioner::Place.where('id = parent_id').find_each do |place|
      place.update_columns(parent_id: nil) # rubocop:disable Rails/SkipsModelValidations
    end
    puts '✓ Fixed self-root places'
  end
end
