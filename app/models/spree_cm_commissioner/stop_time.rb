require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class StopTime < SpreeCmCommissioner::Base
    belongs_to :trip, class_name: 'SpreeCmCommissioner::Trip'
  end
end
