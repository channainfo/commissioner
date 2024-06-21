FactoryBot::define do
  factory :cm_notification_taxon, class: SpreeCmCommissioner::NotificationTaxon do
    customer_notification { create(:customer_notification) }
    taxon { create(:taxon) }
  end
end
