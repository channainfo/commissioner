module SpreeCmCommissioner
  module OptionTypeAttrType
    extend ActiveSupport::Concern

    ATTRIBUTE_TYPES = %w[
      float
      integer
      string
      boolean
      array
      date
      time
      coordinate
      state_selection
      payment_option
      delivery_option
      amenity
      departure_time
      duration
      vehicle_id
      origin
      destination
    ].freeze

    RESERVED_OPTIONS = {
      'location' => 'state_selection',
      'start-date' => 'date',
      'end-date' => 'date',
      'start-time' => 'time',
      'end-time' => 'time',
      'reminder-in-hours' => 'integer',
      'duration-in-hours' => 'integer',
      'duration-in-minutes' => 'integer',
      'duration-in-seconds' => 'integer',
      'payment-option' => 'payment_option',
      'delivery-option' => 'delivery_option',
      'max-quantity-per-order' => 'integer',
      'due-date' => 'integer',
      'month' => 'integer',
      'number-of-adults' => 'integer',
      'number-of-kids' => 'integer',
      'kids-age-max' => 'integer',
      'allowed-extra-adults' => 'integer',
      'allowed-extra-kids' => 'integer',
      'bib-prefix' => 'string',
      'bib-zerofill' => 'integer',
      'bib-display-prefix' => 'boolean',
      'bib-pre-generation-on-create' => 'boolean',
      'seat-number-positions' => 'array',
      'origin' => 'origin',
      'destination' => 'destination',
      'departure-time' => 'time',
      'vehicle' => 'vehicle_id',
      'allow-seat-selection' => 'boolean'
    }.freeze

    included do
      include SpreeCmCommissioner::ParameterizeName

      validates :attr_type, inclusion: { in: ATTRIBUTE_TYPES }
      validates :attr_type, presence: true

      validate :ensure_name_is_not_changed, on: :update

      before_validation :set_reverved_options_attributes, if: :reserved_option?

      after_save :sort_date_time_option_values, if: -> { attr_type == 'date' || attr_type == 'time' }
      after_save :update_variants_metadata, if: :saved_change_to_name?

      ATTRIBUTE_TYPES.each do |attr_type|
        define_method "attr_type_#{attr_type}?" do
          self.attr_type == attr_type
        end
      end
    end

    def reserved_option?
      return name_was.in?(RESERVED_OPTIONS.keys) if name_changed?

      name.in?(RESERVED_OPTIONS.keys)
    end

    def set_reverved_options_attributes
      self.attr_type = RESERVED_OPTIONS[name]
      self.kind = :variant
    end

    def sort_date_time_option_values
      ordered_option_values = option_values.sort_by { |value| Time.zone.parse(value.name) }.reverse
      ordered_option_values.each_with_index do |value, index|
        position = index + 1
        value.update(position: position)
      end
    end

    def update_variants_metadata
      SpreeCmCommissioner::OptionTypeVariantsPublicMetadataUpdaterJob.perform_later(id)
    end

    private

    def ensure_name_is_not_changed
      return unless name_changed?
      return unless reserved_option?

      errors.add(:name, 'cannot be changed after it has been set')
    end
  end
end
