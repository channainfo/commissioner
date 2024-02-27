require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class LineItemSeat < SpreeCmCommissioner::Base
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :seat, class_name: 'SpreeCmCommissioner::VehicleSeat'
  end
end
