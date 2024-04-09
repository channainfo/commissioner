module SpreeCmCommissioner
  module ProductTypeBitwise
    extend ActiveSupport::Concern

    BIT_SEGMENT = {
      accommodation: 0b1,
      ecommerce: 0b10,
      service: 0b100
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
