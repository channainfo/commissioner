module SpreeCmCommissioner
  class TaxonVendor < SpreeCmCommissioner::Base
    belongs_to :taxon, class_name: 'Spree::Taxon', optional: true
    belongs_to :vendor, class_name: 'Spree::Vendor', optional: true

    acts_as_list scope: :vendor

    validates :taxon_id, presence: true
    validates :vendor_id, presence: true, uniqueness: { scope: :taxon_id }
  end
end
