module SpreeCmCommissioner
  module VideoOnDemandBitwise
    extend ActiveSupport::Concern

    # must add migration to cm_guests when adding new field.
    QUALITY_BIT_FIELDS = {
      low: 0b1,           # quality_320p
      standard: 0b10,     # quality_480p
      medium: 0b100,      # quality_720p
      high: 0b1000        # quality_1080p
    }.freeze

    PROTOCOL_BIT_FIELDS = {
      p_hls: 0b1,
      p_dash: 0b10,
      p_file: 0b100
    }.freeze

    def quality? = quality != 0
    def protocol? = protocol != 0

    # Quality
    QUALITY_BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        quality_value_enabled?(bit_value)
      end
    end

    def quality_fields
      QUALITY_BIT_FIELDS.filter_map do |field, bit_value|
        field if video_quality & bit_value != 0
      end
    end

    def quality_value_enabled?(bit_value)
      video_quality & bit_value != 0
    end

    # Protocol
    PROTOCOL_BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        video_protocol & bit_value != 0
      end
    end

    def protocol_fields
      PROTOCOL_BIT_FIELDS.filter_map do |field, bit_value|
        field if video_protocol & bit_value != 0
      end
    end
  end
end
