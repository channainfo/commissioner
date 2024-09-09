namespace :data do
  desc 'Seeds location option values'
  task seed_kh_location_option_values: :environment do
    location_type = Spree::OptionType.find_or_initialize_by(name: 'location', presentation: 'Location', attr_type: 'state_selection')
    cambodia = Spree::Country.find_or_create_by(name: 'Cambodia')  # run `rake data:seed_kh_provinces` first

    cambodia.states.each do |province|
      location_type.option_values.find_or_initialize_by(name: province.id, presentation: province.name)
    end
    location_type.save

    puts "Created #{location_type.option_values.count} location option values"
  end
end
