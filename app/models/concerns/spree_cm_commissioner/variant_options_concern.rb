module SpreeCmCommissioner
  module VariantOptionsConcern
    extend ActiveSupport::Concern

    included do
      before_save :set_options_to_public_metadata

      delegate :location,
               :start_date,
               :start_time,
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
               :bib_prefix,
               :bib_zerofill,
               :bib_display_prefix?,
               :bib_pre_generation_on_create?,
               :seat_number_positions,
               :seat_number_layouts,
               to: :options
    end

    def options
      @options ||= VariantOptions.new(self)
    end

    def options_in_hash
      public_metadata[:cm_options]
    end

    def option_value_name_for(option_type_name: nil)
      return options_in_hash[option_type_name] if options_in_hash.present? # empty is not considered present?

      find_option_value_name_for(option_type_name: option_type_name)
    end

    def find_option_value_name_for(option_type_name: nil)
      option_values.detect { |o| o.option_type.name.downcase.strip == option_type_name.downcase.strip }.try(:name)
    end

    # No need to fallback to event start date to avoid n+1.
    # To get end_time duration of event, include event when needed instead.
    def start_date_time
      return nil if start_date.blank?
      return start_date if start_time.blank?

      start_date.change(hour: start_time.hour, min: start_time.min, sec: start_time.sec)
    end

    # No need to fallback to event end date to avoid n+1.
    # To get end_time duration of event, include event when needed instead.
    def end_date_time
      return nil if end_date.blank?
      return end_date if end_time.blank?

      end_date.change(hour: end_time.hour, min: end_time.min, sec: end_time.sec)
    end

    def end_date
      return start_date + options.total_duration_in_seconds.seconds if start_date.present? && options.total_duration_in_seconds.positive?

      options.end_date
    end

    def end_time
      return start_time + options.total_duration_in_seconds.seconds if start_time.present? && options.total_duration_in_seconds.positive?

      options.end_time
    end

    def post_paid?
      options.payment_option == 'post-paid'
    end

    # save optins to public_metadata so we don't have to query option types & option values when needed them.
    # once variant changed, we update metadata.
    def set_options_to_public_metadata
      self.public_metadata ||= {}

      latest_options_in_hash = option_values.each_with_object({}) do |option_value, hash|
        option_type_name = option_value.option_type.name
        hash[option_type_name] = find_option_value_name_for(option_type_name: option_type_name)
      end

      self.public_metadata[:cm_options] = latest_options_in_hash
    end

    def set_options_to_public_metadata!
      set_options_to_public_metadata
      save!
    end
  end
end
