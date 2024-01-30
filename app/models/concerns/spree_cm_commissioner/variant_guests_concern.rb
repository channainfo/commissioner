module SpreeCmCommissioner
  module VariantGuestsConcern
    extend ActiveSupport::Concern

    DEFAULT_KIDS_AGE_MAX = 17
    DEFAULT_NUMBER_OF_GUESTS = 1

    def adults_option_value
      option_value('adults')
    end

    def kids_option_value
      option_value('kids')
    end

    def kids_age_max_option_value
      option_value('kids-age-max')
    end

    # can consider as customers.
    # 1 by default in case adult & kid is not provided.
    def number_of_guests
      [DEFAULT_NUMBER_OF_GUESTS, number_of_adults + number_of_kids].max
    end

    def number_of_adults
      adults_option_value&.to_i || 0
    end

    def number_of_kids
      kids_option_value&.to_i || 0
    end

    # <= 17
    def kids_age_max
      kids_age_max_option_value&.to_i || DEFAULT_KIDS_AGE_MAX
    end

    # > 17
    def adults_age_min
      kid_age_max
    end
  end
end
