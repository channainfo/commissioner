module SpreeCmCommissioner
  class GuestOccupationPromotionRule < Base
    belongs_to :occupation, class_name: 'Spree::Taxon'
    belongs_to :promotion_rule, class_name: 'Spree::PromotionRule'
  end
end
