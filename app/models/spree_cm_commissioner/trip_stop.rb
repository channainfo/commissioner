require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class TripStop < SpreeCmCommissioner::Base
    acts_as_list column: :sequence, scope: :trip_id
    enum :stop_type, { boarding: 0, drop_off: 1 }

    belongs_to :trip, class_name: 'Spree::Variant'
    belongs_to :stop, class_name: 'SpreeCmCommissioner::Place'

    before_validation :set_stop_name
    after_destroy :decrement_trip_count
    after_commit :create_vendor_stop
    validates :stop_id, uniqueness: { scope: :trip_id }

    def set_stop_name
      self.stop_name = stop.name if stop.present?
    end

    def create_vendor_stop
      vendor_stop = vendor.vendor_stops.where(stop_id: stop_id, stop_type: stop_type).first_or_create
      vendor_stop.update(trip_count: vendor_stop.trip_count.to_i + 1)
    end

    private

    def decrement_trip_count
      vendor.vendor_stops.where(stop_id: stop_id, stop_type: stop_type).find_each do |vendor_stop|
        vendor_stop.update(trip_count: [vendor_stop.trip_count - 1, 0].max)
      end
    end

    def vendor
      Spree::Product.find(trip&.product_id).vendor
    end
  end
end
