module DeliveryMethods
  module DatabaseDecorator
    def deliver
      recipient.ensure_unique_database_delivery_method(attributes)
    end
  end
end

Noticed::DeliveryMethods::Database.prepend(DeliveryMethods::DatabaseDecorator)
