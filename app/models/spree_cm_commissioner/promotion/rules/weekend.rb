module SpreeCmCommissioner
  module Promotion
    module Rules
      class Weekend < Date
        # override
        def date_eligible?(date)
          date.on_weekend?
        end
      end
    end
  end
end
