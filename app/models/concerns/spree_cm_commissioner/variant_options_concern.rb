module SpreeCmCommissioner
  module VariantOptionsConcern
    extend ActiveSupport::Concern

    def options
      @options ||= VariantOptions.new(self)
    end

    delegate :location,
             :reminder_in_hours,
             :duration_in_hours,
             :duration_in_minutes,
             :duration_in_seconds,
             :payment_option,
             :delivery_option,
             :max_quantity_per_order,
             :due_date,
             :month,
             :number_of_adults,
             :number_of_kids,
             :kids_age_max,
             :allowed_extra_adults,
             :allowed_extra_kids,
             :number_of_guests,
             :bib_number_prefix,
             to: :options

    def start_date_time
      return nil if start_date.blank?
      return start_date if start_time.blank?

      start_date.change(hour: start_time.hour, min: start_time.min, sec: start_time.sec)
    end

    def end_date_time
      return nil if end_date.blank?
      return end_date if end_time.blank?

      end_date.change(hour: end_time.hour, min: end_time.min, sec: end_time.sec)
    end

    def start_date
      options.start_date || event&.from_date
    end

    def end_date
      return start_date + options.total_duration_in_seconds.seconds if start_date.present? && options.total_duration_in_seconds.positive?

      options.end_date || event&.to_date
    end

    def start_time
      options.start_time || event&.from_date
    end

    def end_time
      return start_time + options.total_duration_in_seconds.seconds if start_time.present? && options.total_duration_in_seconds.positive?

      options.end_time || event&.to_date
    end

    def post_paid?
      options.payment_option == 'post-paid'
    end
  end
end
