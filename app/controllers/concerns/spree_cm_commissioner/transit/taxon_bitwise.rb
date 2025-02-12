module SpreeCmCommissioner
  module Transit
    module TaxonBitwise
      extend ActiveSupport::Concern

      BIT_STOP = 0b001
      BIT_STATION = 0b010
      BIT_BRANCH = 0b100
      BIT_LOCATION = 0b1000

      included do
        attr_accessor :stop, :station, :branch, :location

        before_validation :at_least_one_checkbox_selected
      end

      def stop?
        data_type & BIT_STOP != 0
      end

      def station?
        data_type & BIT_STATION != 0
      end

      def branch?
        data_type & BIT_BRANCH != 0
      end

      def location?
        data_type & BIT_LOCATION != 0
      end

      private

      def at_least_one_checkbox_selected
        if stop.nil? && station.nil? && branch.nil? && location.nil?
          nil
        elsif stop.to_i.zero? && station.to_i.zero? && branch.to_i.zero? && location.to_i.zero?
          errors.add(:base, 'At least one checkbox (stop, branch, or location) must be selected')
        end
      end
    end
  end
end
