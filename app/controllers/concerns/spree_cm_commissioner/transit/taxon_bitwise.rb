module SpreeCmCommissioner
  module Transit
    module TaxonBitwise
      extend ActiveSupport::Concern

      BIT_STOP     = 0b001
      BIT_BRANCH   = 0b010
      BIT_LOCATION = 0b100

      included do
        attr_accessor :stop, :branch, :location
        before_validation :at_least_one_checkbox_selected
      end

      def stop?
        self.data_type & BIT_STOP != 0
      end

      def branch?
        self.data_type & BIT_BRANCH != 0
      end

      def location?
        self.data_type & BIT_LOCATION != 0
      end

      private

      def at_least_one_checkbox_selected
        if stop.nil? && branch.nil? && location.nil?
          return
        elsif stop.to_i.zero? && branch.to_i.zero? && location.to_i.zero?
          errors.add(:base, 'At least one checkbox (stop, branch, or location) must be selected')
        end
      end
    end
  end
end
