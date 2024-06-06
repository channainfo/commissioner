module SpreeCmCommissioner
  module OptionTypeAttrType
    extend ActiveSupport::Concern

    ATTRIBUTE_TYPES = %w[
      float
      integer
      string
      boolean
      date
      time
      coordinate
      state_selection
      payment_option
      delivery_option
    ].freeze

    RESERVED_OPTIONS = {
      'location' => 'state_selection',
      'start-date' => 'date',
      'end-date' => 'date',
      'start-time' => 'time',
      'reminder-in-time' => 'time',
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
      'allowed-extra-kids' => 'integer'
    }.freeze

    included do
      include SpreeCmCommissioner::ParameterizeName

      validates :attr_type, inclusion: { in: ATTRIBUTE_TYPES }
      validates :attr_type, presence: true

      before_validation :set_reverved_options_attributes, if: :reserved_option?

      ATTRIBUTE_TYPES.each do |attr_type|
        define_method "attr_type_#{attr_type}?" do
          self.attr_type == attr_type
        end
      end
    end

    def reserved_option?
      name.in?(RESERVED_OPTIONS.keys)
    end

    def set_reverved_options_attributes
      self.attr_type = RESERVED_OPTIONS[name]
      self.kind = :variant
    end
  end
end
