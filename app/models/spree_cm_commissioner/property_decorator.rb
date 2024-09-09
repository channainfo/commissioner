module SpreeCmCommissioner
  module PropertyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName
    end
  end
end

unless Spree::Property.included_modules.include?(SpreeCmCommissioner::PropertyDecorator)
  Spree::Property.prepend(SpreeCmCommissioner::PropertyDecorator)
end
