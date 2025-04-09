class GenerateDefaultNumberOfGuestsToVariant < ActiveRecord::Migration[7.0]
  def change
    Spree::Variant.find_each do |variant|
      variant.number_of_adults = variant.option_value_name_for(option_type_name: 'number-of-adults')&.to_i || 1
      variant.number_of_kids = variant.option_value_name_for(option_type_name: 'number-of-kids')&.to_i || 0
      variant.save(validate: false)
    end
  end
end
