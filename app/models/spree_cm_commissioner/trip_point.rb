require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripPoint < SpreeCmCommissioner::Base
    enum point_type: { boarding: 0, drop_off: 1 }

    belongs_to :trip, class_name: 'SpreeCmCommissioner::Trip'
    belongs_to :taxon, class_name: 'Spree::Taxon'

    # validate :point_type, presence: true
  end
end
