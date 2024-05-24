require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripStop < SpreeCmCommissioner::Base
    before_validation :set_stop_name
    after_commit :create_operator_places, on: :create
    include SpreeCmCommissioner::Transit::StopType
    acts_as_list column: :sequence, scope: :trip_id
    # enum stop_type: { boarding: 0, drop_off: 1 }

    has_many :operator_places, foreign_key: :place_id, class_name: 'SpreeCmCommissioner::OperatorPlace', dependent: :destroy
    has_many :vendors, class_name: 'Spree::Vendor', through: :operator_places

    belongs_to :trip, class_name: 'SpreeCmCommissioner::Trip'
    belongs_to :stop, class_name: 'Spree::Taxon'

    validates :stop_id, uniqueness: { scope: :trip_id }

    def set_stop_name
      self.stop_name = stop.name
    end

    def create_operator_places
      byebug
      operator_id = current_vendor.id
    end
  end
end
