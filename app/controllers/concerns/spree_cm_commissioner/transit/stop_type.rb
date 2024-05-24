module SpreeCmCommissioner
  module Transit
    module StopType
      extend ActiveSupport::Concern

      included do
        enum stop_type: { boarding: 0, drop_off: 1 }
      end
    end
  end
end
