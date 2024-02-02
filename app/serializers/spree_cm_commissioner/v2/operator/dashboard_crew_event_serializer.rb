module SpreeCmCommissioner
  module V2
    module Operator
      class DashboardCrewEventSerializer < BaseSerializer
        attributes :taxon_id, :name, :permalink, :from_date, :to_date

        set_id do |event, _params|
          event.taxon_id
        end
      end
    end
  end
end
