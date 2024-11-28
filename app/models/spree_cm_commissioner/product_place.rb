module SpreeCmCommissioner
  class ProductPlace < Base
    self.inheritance_column = '_type_disabled'

    belongs_to :product, class_name: 'Spree::Product', optional: false
    belongs_to :place, class_name: 'SpreeCmCommissioner::Place', optional: false

    validates :place_id, uniqueness: { scope: :product_id }

    enum type: { venue: 0, nearby_place: 1 }
  end
end
