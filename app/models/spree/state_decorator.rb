module Spree
  module StateDecorator
    def self.prepended(base)
      base.has_many :vendors

      def update_total_inventory
        update(total_inventory: vendors.pluck(:total_inventory).sum)
      end
    end
  end
end

Spree::State.prepend(Spree::StateDecorator) if Spree::State.included_modules.exclude?(Spree::StateDecorator)
