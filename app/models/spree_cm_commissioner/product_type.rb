require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ProductType < ApplicationRecord
    default_scope { where(enabled: true) }

    validates_presence_of :name, :presentation
    validates_uniqueness_of :name

    # Modified enabled definition, to exclude product product_type, for lacking of relevance
    def self.enabled
      where(enabled: true)
    end
  end
end
