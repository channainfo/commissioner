module SpreeCmCommissioner
  module V2
    module Operator
      class DashboardCrewEventSerializer < BaseSerializer
        attributes :taxon_id, :name, :permalink, :from_date, :to_date, :updated_at

        has_many :classifications, serializer: :classification do |object|
          Spree::Classification.where(id: object.product_taxon_ids)
        end

        set_id do |event, _params|
          event.taxon_id
        end
      end
    end
  end
end
