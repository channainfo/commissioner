module SpreeCmCommissioner
  class TripConnection < ApplicationRecord
    belongs_to :from_trip, class_name: 'Spree::Variant'
    belongs_to :to_trip, class_name: 'Spree::Variant'

    validate :both_trip_cannot_be_the_same
    before_validation :calculate_connection_time_minutes
    validates :from_trip_id, uniqueness: { scope: :to_trip_id }

    private

    def calculate_connection_time_minutes
      return if from_trip.nil? || to_trip.nil?

      arrival_seconds   = from_trip.trip.arrival_time.seconds_since_midnight
      departure_seconds = to_trip.trip.departure_time.seconds_since_midnight

      layover_seconds = departure_seconds - arrival_seconds
      layover_seconds += 86_400 if layover_seconds.negative?

      connection_time_in_minutes = layover_seconds / 60

      if connection_time_in_minutes.between?(0, 180)
        self.connection_time_minutes = connection_time_in_minutes.to_i
      else
        errors.add(:base, 'Connection time must be less than 3 hours')
      end
    end

    def both_trip_cannot_be_the_same
      return unless from_trip.id == to_trip.id

      errors.add(:base, 'Both trip cannot be the same')
    end
  end
end
