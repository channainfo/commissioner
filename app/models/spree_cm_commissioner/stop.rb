require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Stop < SpreeCmCommissioner::Place
    def validate_reference?
      false
    end
  end
end