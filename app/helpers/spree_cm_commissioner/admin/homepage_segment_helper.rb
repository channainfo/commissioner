module SpreeCmCommissioner
  module Admin
    module HomepageSegmentHelper
      def badge_class_for_segment(segment_name)
        case segment_name.to_sym
        when :general
          'badge badge-primary text-uppercase'
        when :ticket
          'badge badge-secondary text-uppercase'
        when :tour
          'badge badge-info text-uppercase'
        when :accommodation
          'badge badge-warning text-uppercase'
        else
          'badge'
        end
      end

      def calculate_segment_value(params)
        segment_params = params.slice(*SpreeCmCommissioner::HomepageSectionBitwise::BIT_SEGMENT.keys)

        return nil unless segment_params.values.any?

        segment_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end
    end
  end
end
