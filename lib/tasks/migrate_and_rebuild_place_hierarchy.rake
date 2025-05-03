namespace :spree_cm_commissioner do
  desc 'Migrate and Rebuild place hierarchy..'
  task migrate_and_rebuild_place_hierarchy: :environment do
    puts 'Resetting column information :lft and :rgt columns...'
    SpreeCmCommissioner::Place.reset_column_information
    SpreeCmCommissioner::Place.rebuild!
    puts 'Place hierarchy rebuild completed successfully!'
  end
end
