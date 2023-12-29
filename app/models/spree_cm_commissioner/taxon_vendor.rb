class SpreeCmCommissioner::TaxonVendor < SpreeCmCommissioner::Base
  belongs_to :taxon, class_name: 'Spree::Taxon'
  belongs_to :vendor, class_name: 'Spree::Vendor'

  acts_as_list scope: :vendor

  validates :vendor_id, uniqueness: { scope: :taxon_id, allow_nil: true }
end
