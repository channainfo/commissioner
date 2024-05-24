module SpreeCmCommissioner
  class NotificationTaxon < SpreeCmCommissioner::Base
    belongs_to :customer_notification, class_name: 'SpreeCmCommissioner::CustomerNotification'
    belongs_to :taxon, class_name: 'Spree::Taxon'
  end
end
