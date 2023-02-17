module SpreeCmCommissioner
  module StateDecorator
    def self.prepended(base)
      base.has_many :vendors

      def update_total_inventory
        update(total_inventory: vendors.pluck(:total_inventory).sum)
      end
    end
  end
end

Spree::State.prepend(SpreeCmCommissioner::StateDecorator) unless Spree::State.included_modules.include?(SpreeCmCommissioner::StateDecorator)
