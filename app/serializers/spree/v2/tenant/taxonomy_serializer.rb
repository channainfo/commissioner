module Spree
  module V2
    module Tenant
      class TaxonomySerializer < BaseSerializer
        set_type   :taxonomy

        attributes :name, :position, :public_metadata
      end
    end
  end
end
