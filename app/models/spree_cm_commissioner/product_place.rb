module SpreeCmCommissioner
  class ProductPlace < Base
    self.inheritance_column = '_type_disabled'

    belongs_to :product, class_name: 'Spree::Product', optional: true
    belongs_to :place, class_name: 'SpreeCmCommissioner::Place', optional: true

    enum type: { venue: 0, nearby_place: 1 }
  end
end
