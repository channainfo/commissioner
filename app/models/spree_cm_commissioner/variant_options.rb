module SpreeCmCommissioner
  class VariantOptions
    attr_reader :variant

    def initialize(variant)
      @variant = variant
    end

    DEFAULT_KIDS_AGE_MAX = 17
    DEFAULT_NUMBER_OF_ADULTS = 1

    # these method read option value from public metadata first
    # if no public metadata found, it will find in db.
    def option_value_name_for(option_type_name: nil)
      variant.option_value_name_for(option_type_name: option_type_name)
    end

    def location
      @location ||= option_value_name_for(option_type_name: 'location')&.to_i
    end

    def start_date
      @start_date ||= begin
        date = option_value_name_for(option_type_name: 'start-date')
        Time.zone.parse(date) if date.present?
      end
    end

    def end_date
      @end_date ||= begin
        date = option_value_name_for(option_type_name: 'end-date')
        Time.zone.parse(date) if date.present?
      end
    end

    def start_time
      @start_time ||= begin
        time = option_value_name_for(option_type_name: 'start-time')
        Time.zone.parse(time) if time.present?
      end
    end

    def end_time
      @end_time ||= begin
        time = option_value_name_for(option_type_name: 'end-time')
        Time.zone.parse(time) if time.present?
      end
    end

    def reminder_in_hours
      @reminder_in_hours ||= option_value_name_for(option_type_name: 'reminder-in-hours')&.to_i
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

    def total_duration_in_seconds
      total_duration_in_seconds = 0

      total_duration_in_seconds += duration_in_hours * 3600 if duration_in_hours.present?
      total_duration_in_seconds += duration_in_minutes * 60 if duration_in_minutes.present?
      total_duration_in_seconds += duration_in_seconds if duration_in_seconds.present?

      total_duration_in_seconds
    end

    def payment_option
      @payment_option ||= option_value_name_for(option_type_name: 'payment-option')
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

    def kids_age_max
      @kids_age_max ||= option_value_name_for(option_type_name: 'kids-age-max')&.to_i || DEFAULT_KIDS_AGE_MAX
    end

    def allowed_extra_adults
      @allowed_extra_adults ||= option_value_name_for(option_type_name: 'allowed-extra-adults')&.to_i || 0
    end

    def allowed_extra_kids
      @allowed_extra_kids ||= option_value_name_for(option_type_name: 'allowed-extra-kids')&.to_i || 0
    end

    def bib_prefix
      @bib_prefix ||= option_value_name_for(option_type_name: 'bib-prefix')
    end

    def bib_zerofill
      @bib_zerofill ||= option_value_name_for(option_type_name: 'bib-zerofill')&.to_i || 3
    end

    def bib_display_prefix?
      @bib_display_prefix ||= option_value_name_for(option_type_name: 'bib-display-prefix')&.to_i || 1
      @bib_display_prefix == 1
    end

    def seat_number_positions
      @seat_number_positions ||= option_value_name_for(option_type_name: 'seat-number-positions')&.split(',')
    end

    def seat_number_layouts
      @seat_number_layouts ||= option_value_name_for(option_type_name: 'seat-number-layouts')&.split(',')
    end

    # can consider as customers.
    def number_of_guests
      number_of_adults + number_of_kids
    end
  end
end
