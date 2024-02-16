module SpreeCmCommissioner
  module HomepageSectionBitwise
    extend ActiveSupport::Concern

    BIT_SEGMENT = {
      general: 0b00001,
      ticket: 0b00010,
      tour: 0b00100,
      accommodation: 0b01000
    }.freeze

    BIT_SEGMENT.each do |segment, bit_value|
      define_method "#{segment}?" do
        segment_enabled?(bit_value)
      end
    end

    def segments
      BIT_SEGMENT.filter_map do |segment_value, bit_value|
        segment_value if segment_enabled?(bit_value)
      end
    end

    def segment_enabled?(bit_value)
      segment & bit_value != 0
    end
  end
end
