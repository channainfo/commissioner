module SpreeCmCommissioner
  module V2
    module Operator
      class DashboardCrewEventSerializer < BaseSerializer
        attributes :id, :name, :permalink, :from_date, :to_date, :updated_at

        has_many :children_classifications, serializer: :classification
        has_one :category_icon, serializer: SpreeCmCommissioner::V2::Storefront::AssetSerializer
      end
    end
  end
end
