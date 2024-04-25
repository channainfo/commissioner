require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripStop < SpreeCmCommissioner::Base
    enum stop_type: { boarding: 0, drop_off: 1 }

    belongs_to :trip, class_name: 'SpreeCmCommissioner::Trip'
    belongs_to :stop, class_name: 'Spree::Taxon'

    before_validation :set_stop_name

    validates :stop_id, uniqueness: { scope: :trip_id }

    def set_stop_name
      self.stop_name = stop.name
    end
  end
end
