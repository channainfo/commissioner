module SpreeCmCommissioner
  class UserTaxon < Base
    belongs_to :user, class_name: Spree.user_class.to_s, optional: false
    belongs_to :taxon, class_name: 'Spree::Taxon', optional: false
  end
end
