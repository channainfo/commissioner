require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripStop < SpreeCmCommissioner::Base
    enum stop_type: { boarding: 0, drop_off: 1 }

    belongs_to :trip, class_name: 'SpreeCmCommissioner::Trip'
    belongs_to :taxon, class_name: 'Spree::Taxon'

    validates :stop_id, uniqueness: { scope: :trip_id }
  end
end
