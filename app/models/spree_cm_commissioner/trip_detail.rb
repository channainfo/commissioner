require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripDetail < SpreeCmCommissioner::Base
    belongs_to :route, class_name: 'Spree::Product'
  end
end
