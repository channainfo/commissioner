module SpreeCmCommissioner
  class TripConnection < ApplicationRecord
    attr_accessor :hours, :minutes

    belongs_to :from_trip, class_name: 'Spree::Variant'
    belongs_to :to_trip, class_name: 'Spree::Variant'

    validate :both_trip_cannot_be_the_same
    before_validation :calculate_connection_time_minutes

    private

    def calculate_connection_time_minutes
      return if from_trip.nil? || to_trip.nil?

      connection_time_in_minutes = (to_trip.options.departure_time - from_trip.options.arrival_time) / 60
      if connection_time_in_minutes.between?(0, 180)
        self.connection_time_minutes = connection_time_in_minutes
      else
        errors.add(:base, 'Connection time should be between 0 and 180 minutes')
      end
    end

    def both_trip_cannot_be_the_same
      return unless from_trip.id == to_trip.id

      errors.add(:base, 'Both trip cannot be the same')
    end
  end
end
