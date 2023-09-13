require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Branch < SpreeCmCommissioner::Place
    belongs_to :state,  class_name: 'Spree::State', optional: true
    belongs_to :vendor, class_name: 'Spree::Vendor'

    validates :vendor_id, presence: true

    def validate_reference?
      false
    end
  end
end
