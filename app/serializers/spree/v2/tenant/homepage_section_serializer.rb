module Spree
  module V2
    module Tenant
      class HomepageSectionSerializer < BaseSerializer
        attributes :id, :title, :segments, :description,
                   :active, :position, :created_at, :updated_at

        has_many :homepage_section_relatables, serializer: ::Spree::V2::Tenant::HomepageSectionRelatableSerializer
      end
    end
  end
end
