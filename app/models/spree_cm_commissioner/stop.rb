require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Stop < SpreeCmCommissioner::Place
    belongs_to :branch, class_name: 'SpreeCmCommissioner::Branch'
    belongs_to :state,  class_name: 'Spree::State', optional: true
    belongs_to :vendor, class_name: 'Spree::Vendor'

    after_save :add_to_option_value

    def validate_reference?
      false
    end

    def add_to_option_value
      origin = Spree::OptionType.find_by(attr_type: 'origin')&.id
      destination = Spree::OptionType.find_by(attr_type: 'destination')&.id

      Spree::OptionValue.create(option_type_id: origin, name: name, presentation: id)
      Spree::OptionValue.create(option_type_id: destination, name: name, presentation: id)
    end
  end
end
