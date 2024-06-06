module SpreeCmCommissioner
  module VariantOptionsConcern
    extend ActiveSupport::Concern

    DEFAULT_KIDS_AGE_MAX = 17
    DEFAULT_NUMBER_OF_ADULTS = 1

    def location
      @location ||= option_value_name_for(option_type_name: 'location')&.to_i
    end

    def start_date
      @start_date ||= option_value_name_for(option_type_name: 'start-date')
    end

    def end_date
      @end_date ||= option_value_name_for(option_type_name: 'end-date')
    end

    def start_time
      @start_time ||= option_value_name_for(option_type_name: 'start-time')
    end

    def reminder_in_time
      @reminder_in_time ||= option_value_name_for(option_type_name: 'reminder-in-time')
    end

    def duration_in_hours
      @duration_in_hours ||= option_value_name_for(option_type_name: 'duration-in-hours')&.to_i
    end

    def duration_in_minutes
      @duration_in_minutes ||= option_value_name_for(option_type_name: 'duration-in-minutes')&.to_i
    end

    def duration_in_seconds
      @duration_in_seconds ||= option_value_name_for(option_type_name: 'duration-in-seconds')&.to_i
    end

    def payment_option
      @payment_option ||= option_value_name_for(option_type_name: 'payment-option')
    end

    def post_paid?
      payment_option == 'post-paid'
    end

    def delivery_option
      @delivery_option ||= option_value_name_for(option_type_name: 'delivery-option')
    end

    def max_quantity_per_order
      @max_quantity_per_order ||= option_value_name_for(option_type_name: 'max-quantity-per-order')&.to_i
    end

    def due_date
      @due_date ||= option_value_name_for(option_type_name: 'due-date')&.to_i
    end

    def month
      @month ||= option_value_name_for(option_type_name: 'month')&.to_i
    end

    def number_of_adults
      @number_of_adults ||= option_value_name_for(option_type_name: 'number-of-adults')&.to_i || DEFAULT_NUMBER_OF_ADULTS
    end

    def number_of_kids
      @number_of_kids ||= option_value_name_for(option_type_name: 'number-of-kids')&.to_i || 0
    end

    # can consider as customers.
    def number_of_guests
      number_of_adults + number_of_kids
    end

    def kids_age_max
      @kids_age_max ||= option_value_name_for(option_type_name: 'kids-age-max')&.to_i || DEFAULT_KIDS_AGE_MAX
    end

    def allowed_extra_adults
      @allowed_extra_adults ||= option_value_name_for(option_type_name: 'allowed-extra-adults')&.to_i || 0
    end

    def allowed_extra_kids
      @allowed_extra_kids ||= option_value_name_for(option_type_name: 'allowed-extra-kids')&.to_i || 0
    end
  end
end
