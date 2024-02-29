module SpreeCmCommissioner
  module V2
    module Operator
      class DashboardCrewEventSerializer < BaseSerializer
        attributes :id, :name, :permalink, :from_date, :to_date, :updated_at

        has_many :children_classifications, serializer: :classification
      end
    end
  end
end
