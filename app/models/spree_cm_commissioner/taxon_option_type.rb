require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class TaxonOptionType < ApplicationRecord
    belongs_to :taxon, class_name: 'Spree::Taxon', dependent: :destroy
    belongs_to :option_type, class_name: 'Spree::OptionType', dependent: :destroy
  end
end
