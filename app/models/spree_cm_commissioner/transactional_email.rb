module SpreeCmCommissioner
  class TransactionalEmail < SpreeCmCommissioner::Base
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :recipient, polymorphic: true
  end
end
