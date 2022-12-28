require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class ProductType < ApplicationRecord
    include SpreeCmCommissioner::DashCaseName

    default_scope { where(enabled: true) }

    validates_presence_of :name, :presentation
    validates_uniqueness_of :name
  end
end