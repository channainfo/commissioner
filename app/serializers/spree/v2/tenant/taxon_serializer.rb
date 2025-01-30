module Spree
  module V2
    module Tenant
      class TaxonSerializer < BaseSerializer
        attributes :name, :pretty_name, :permalink, :seo_title,
                   :description, :from_date, :to_date
      end
    end
  end
end
