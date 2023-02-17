module SpreeCmCommissioner
  module AttrTypeValidation
    extend ActiveSupport::Concern

    included do
      def self.act_as_presentation
        validates :presentation, numericality: { only_integer: true }, if: :integer
        validates :presentation, numericality: { only_float: true }, if: :float
        validates :presentation, inclusion: %w[1 0], if: :boolean
      end
    end

    def option_type
      @option_type ||= Spree::OptionType.find_by(id: option_type_id)
    end

    private

    def integer
      option_type&.attr_type == 'integer'
    end

    def float
      option_type&.attr_type == 'float'
    end

    def boolean
      option_type&.attr_type == 'boolean'
    end
  end
end
