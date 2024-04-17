require_dependency 'spree_cm_commissioner'
module SpreeCmCommissioner
  class Trip < SpreeCmCommissioner::Base
    attr_accessor :hours, :minutes, :seconds

    before_validation :convert_duration_to_seconds

    belongs_to :route, class_name: 'Spree::Product'
    validates :departure_time, presence: true

    has_many :trip_points, class_name: 'SpreeCmCommissioner::TripPoint', dependent: :destroy

    validates :duration, numericality: { greater_than: 0 }
    validate :origin_and_destination_cannot_be_the_same

    accepts_nested_attributes_for :trip_points, allow_destroy: true

    def convert_duration_to_seconds
      self.duration = (hours.to_i * 3600) + (minutes.to_i * 60) + seconds.to_i
    end

    def duration_in_hms
      return { hours: 0, minutes: 0, seconds: 0 } if duration.nil?

      hours = duration / 3600
      minutes = (duration % 3600) / 60
      seconds = duration % 60
      { hours: hours, minutes: minutes, seconds: seconds }
    end

    private

    def origin_and_destination_cannot_be_the_same
      return unless origin_id == destination_id

      errors.add(:base, 'Origin and destination cannot be the same')
    end
  end
end
