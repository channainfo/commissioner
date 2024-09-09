module Spree
  module Variants
    class VisableOptionsPresenter < OptionsPresenter
      delegate :visible_option_values, to: :variant

      # override
      def to_sentence
        options = visible_option_values
        options = sort_options(options)
        options = present_options(options)

        join_options(options)
      end
    end
  end
end
