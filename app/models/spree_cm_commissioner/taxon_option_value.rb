require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class TaxonOptionValue < ApplicationRecord
    belongs_to :taxon, class_name: 'Spree::Taxon', dependent: :destroy
    belongs_to :option_value, class_name: 'Spree::OptionValue', dependent: :destroy
  end
end
