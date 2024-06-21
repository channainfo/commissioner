module SpreeCmCommissioner
  module Orders
    module GenerateCommissionsDecorator
      # override
      def generate_order_commissions(order:)
        return failure(order) unless order.state == 'complete'

        vendor_commissions = generate_commissions_group_by_vendor_ids(order)
        vendor_commissions.each do |vendor_id, amount|
          order.commissions.create!(amount: amount, vendor_id: vendor_id)
        end

        success(order: order)
      end

      def generate_commissions_group_by_vendor_ids(order)
        order.line_items.each_with_object(Hash.new(0)) do |line_item, commissions|
          commissions[line_item.vendor_id] += line_item.commission_amount if line_item.vendor_id.present?
        end
      end
    end
  end
end

unless Spree::Orders::GenerateCommissions.included_modules.include?(SpreeCmCommissioner::Orders::GenerateCommissionsDecorator)
  Spree::Orders::GenerateCommissions.prepend(SpreeCmCommissioner::Orders::GenerateCommissionsDecorator)
end
