require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class OperatorPlace < ApplicationRecord
    include SpreeCmCommissioner::Transit::StopType
    belongs_to :operator, class_name: 'Spree::Vendor'
    belongs_to :place, class_name: 'Spree::Taxon'
  end
end
