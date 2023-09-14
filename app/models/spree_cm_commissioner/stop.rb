require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Stop < SpreeCmCommissioner::Place
    belongs_to :branch, class_name: 'SpreeCmCommissioner::Branch'
    belongs_to :state,  class_name: 'Spree::State', optional: true

    def validate_reference?
      false
    end
  end
end
