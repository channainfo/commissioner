module SpreeCmCommissioner
  module Promotion
    module Rules
      class FixedDate < Date
        preference :start_date, :string
        preference :length, :integer, default: 1

        # override
        def date_eligible?(date)
          date.between?(start_rule_date, end_rule_date)
        end

        def start_rule_date
          preferred_start_date&.to_date
        end

        def end_rule_date
          return nil if start_rule_date.nil? || preferred_length.nil?

          start_rule_date + preferred_length.days - 1
        end
      end
    end
  end
end
