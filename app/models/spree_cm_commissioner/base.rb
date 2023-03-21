require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Base < Spree::Base
    self.abstract_class = true
  end
end
