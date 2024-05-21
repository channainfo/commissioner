module SpreeCmCommissioner
  class CustomerTaxon < Base
    belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'
    belongs_to :taxon, class_name: 'Spree::Taxon'
  end
end
