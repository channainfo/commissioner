module SpreeCmCommissioner
  module OptionValueAttrType
    extend ActiveSupport::Concern

    included do
      validates :name, numericality: { only_integer: true }, if: :attr_type_integer?
      validates :name, numericality: { only_float: true }, if: :attr_type_float?
      validates :name, inclusion: %w[1 0], if: :attr_type_boolean?
      validates :name, inclusion: { in: %w[delivery pickup] }, if: :attr_type_delivery_option?

      validate :ensure_name_is_not_changed, on: :update
      validate :validate_coordinate, if: :attr_type_coordinate?

      before_validation :construct_time, if: :attr_type_time?
      before_validation :construct_date, if: :attr_type_date?
      before_validation :normalize_items, if: :attr_type_array?

      after_save :update_variants_metadata, if: :saved_change_to_name?

      delegate :reserved_option?,
               to: :option_type

      SpreeCmCommissioner::OptionTypeAttrType::ATTRIBUTE_TYPES.each do |attr_type|
        define_method "attr_type_#{attr_type}?" do
          option_type.send("attr_type_#{attr_type}?")
        end
      end
    end

    def items
      return nil unless attr_type_array?

      name.split(',')
    end

    def latitude
      return nil unless attr_type_coordinate?
      return nil if name.nil?

      latitude, _longitude = name.split(',').map(&:strip)
      latitude&.to_f
    end

    def longitude
      return nil unless attr_type_coordinate?
      return nil if name.nil?

      _latitude, longitude = name.split(',').map(&:strip)
      longitude&.to_f
    end

    def time
      return nil unless attr_type_time?
      return nil if name.nil?

      Time.zone.parse(name)
    end

    def date
      parse_date(name)
    end

    def parse_date(value)
      return nil if value.nil?

      Date.parse(value)
    rescue Date::Error
      nil
    end

    def update_variants_metadata
      SpreeCmCommissioner::OptionValueVariantsPublicMetadataUpdaterJob.perform_later(id)
    end

    private

    def ensure_name_is_not_changed
      return unless name_changed?
      return unless reserved_option?

      errors.add(:name, 'cannot be changed after it has been set')
    end

    def validate_coordinate
      return if latitude.present? && longitude.present? && latitude.to_f.between?(-90, 90) && longitude.to_f.between?(-180, 180)

      errors.add(:name, :invalid)
    end

    def normalize_items
      self.name = name.split(',').map(&:strip).join(',')
    end

    def construct_time
      hour, minute = extract_time_from_time_select
      hour, minute = extract_time_from_default_format if hour.nil? || minute.nil?

      if hour.nil? || minute.nil?
        # set to nil to failed validation.
        self.name = nil
        self.presentation = nil

        return
      end

      date_time = Time.zone.local(2000, 1, 1, hour, minute, 0)
      self.name = date_time.strftime('%H:%M:%S') # 18:30:00
      self.presentation = date_time.strftime('%I:%M %p') # 06:30 PM
    end

    # f.time_select: "{"time"=>{"(1i)"=>"2024", "(2i)"=>"6", "(3i)"=>"5", "(4i)"=>"17", "(5i)"=>"00"}}"
    def extract_time_from_time_select
      begin
        hash = JSON.parse(name&.gsub('=>', ':') || '')
        hour = hash.dig('time', '(4i)')
        minute = hash.dig('time', '(5i)')
      rescue JSON::ParserError
        hour = nil
        minute = nil
      end

      [hour, minute]
    end

    # "18:30:00"
    def extract_time_from_default_format
      begin
        time = Time.zone.parse(name)
        hour = time&.hour
        minute = time&.min
      rescue StandardError
        hour = nil
        minute = nil
      end

      [hour, minute]
    end

    def construct_date
      self.name = nil if parse_date(name).blank?
      self.presentation = name if parse_date(presentation) != parse_date(name)
    end
  end
end
