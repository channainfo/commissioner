module Spree
  module V2
    module Storefront
      class HomepageSectionSerializer < BaseSerializer
        attributes :id, :title, :segments, :description, :active, :position, :created_at, :updated_at
        has_many :homepage_section_relatables
      end
    end
  end
end
