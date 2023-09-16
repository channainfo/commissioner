module SpreeCmCommissioner
  module StateDecorator
    def self.prepended(base)
      base.whitelisted_ransackable_attributes |= %w[name abbr country_id]
      base.has_many :vendors, foreign_key: 'default_state_id', class_name: 'Spree::Vendor', inverse_of: :default_state, dependent: :nullify
      base.has_many :stops, class_name: 'SpreeCmCommissioner::Place'

      def update_total_inventory
        update(total_inventory: vendors.pluck(:total_inventory).sum)
      end
    end
  end
end

Spree::State.prepend(SpreeCmCommissioner::StateDecorator) unless Spree::State.included_modules.include?(SpreeCmCommissioner::StateDecorator)
