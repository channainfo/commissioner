module SpreeCmCommissioner
  module VariantGuestsConcern
    extend ActiveSupport::Concern

    DEFAULT_KIDS_AGE_MAX = 17
    DEFAULT_NUMBER_OF_ADULTS = 1

    def adults_option_value
      @adults_option_value ||= option_value('adults')
    end

    def kids_option_value
      @kids_option_value ||= option_value('kids')
    end

    def kids_age_max_option_value
      @kids_age_max_option_value ||= option_value('kids-age-max')
    end

    def allowed_extra_adults_option_value
      @allowed_extra_adults_option_value ||= option_value('allowed-extra-adults')
    end

    def allowed_extra_kids_option_value
      @allowed_extra_kids_option_value ||= option_value('allowed-extra-kids')
    end

    # can consider as customers.
    def number_of_guests
      number_of_adults + number_of_kids
    end

    # 1 by default in case adult is not provided.
    def number_of_adults
      [DEFAULT_NUMBER_OF_ADULTS, adults_option_value&.to_i || 0].max
    end

    def number_of_kids
      kids_option_value&.to_i || 0
    end

    def allowed_extra_adults
      allowed_extra_adults_option_value&.to_i || 0
    end

    def allowed_extra_kids
      allowed_extra_kids_option_value&.to_i || 0
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
