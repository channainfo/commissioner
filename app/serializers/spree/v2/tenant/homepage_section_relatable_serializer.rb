module Spree
  module V2
    module Tenant
      class HomepageSectionRelatableSerializer < BaseSerializer
        attributes :homepage_section_id, :position

        has_one :relatable, polymorphic: true
      end
    end
  end
end
