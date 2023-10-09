require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class StopTime < ApplicationRecord
    belongs_to :variants, class_name: 'Spree::Variant', optional: true
  end
end
