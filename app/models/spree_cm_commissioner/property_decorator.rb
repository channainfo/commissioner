module SpreeCmCommissioner
  module PropertyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName

      def base.filter_separator
        "fp_"
      end
    end

    def filter_name
      # name.downcase.to_s
      # name_en = translations_by_locale[:en].name
      # "fp_#{name_en.downcase.to_s}"
      "#{Spree::Property.filter_separator}#{id}"
    end
  end
end

unless Spree::Property.included_modules.include?(SpreeCmCommissioner::PropertyDecorator)
  Spree::Property.prepend(SpreeCmCommissioner::PropertyDecorator)
end
