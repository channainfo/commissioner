module SpreeCmCommissioner
  module VariantOptionValuesConcern
    extend ActiveSupport::Concern

    def started_at_option_value
      option_value('started-at')
    end

    def reminder_option_value
      option_value('reminder')
    end
  end
end
