module SpreeCmCommissioner
  module StoreDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::StorePreference
    end
  end
end

Spree::Store.prepend(SpreeCmCommissioner::StoreDecorator) unless Spree::Store.included_modules.include?(SpreeCmCommissioner::StoreDecorator)
