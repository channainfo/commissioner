module SpreeCmCommissioner
  module OrderDecorator
    # required only in one case, 
    # some of line_items are ecommerce & not digital.
    def delivery_required?
      contain_non_digital_ecommerce?
    end

    def contain_non_digital_ecommerce?
      line_items.select {|item| item.ecommerce? && !item.digital? }.size > 0
    end
  end
end

unless Spree::Order.included_modules.include?(SpreeCmCommissioner::OrderDecorator)
  Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator)
end