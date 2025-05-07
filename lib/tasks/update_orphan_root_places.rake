namespace :spree_cm_commissioner do
  desc 'Update orphan root places...'
  task update_orphan_root_places: :environment do
    count = SpreeCmCommissioner::Place.where(parent_id: 0).update_all(parent_id: nil) # rubocop:disable Rails/SkipsModelValidations
    puts "#{count} orphan root places updated."
  end
end
