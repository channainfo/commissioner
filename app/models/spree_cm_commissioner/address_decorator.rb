module SpreeCmCommissioner
  module AddressDecorator
    def self.prepended(base)
      # Field is not mandatory
      base.enum gender: { :not_selected => 0, :male => 1, :female => 2, :other => 3 }
    end
  end
end

Spree::Address.prepend(SpreeCmCommissioner::AddressDecorator) unless Spree::Address.included_modules.include?(SpreeCmCommissioner::AddressDecorator)
