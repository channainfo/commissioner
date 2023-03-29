module SpreeCmCommissioner
  class AccommodationRequestSchema < ApplicationRequestSchema
    params do
      required(:from_date).value(:date)
      required(:to_date).value(:date)
    end

    rule(:from_date, :to_date) do
      from_date = values[:from_date]
      to_date   = values[:to_date]

      key.failure(:must_be_in_future) if from_date < Time.zone.today
      key.failure(:must_be_later_than_start_date) if from_date > to_date
      key.failure(:stay_is_too_long) if (to_date - from_date).to_i > ENV.fetch('ACCOMMODATION_MAX_STAY_DAYS', 10).to_i
    end
  end
end
