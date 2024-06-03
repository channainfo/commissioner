class CreateSpreeCmNotificationTaxons < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_notification_taxons, if_not_exists: true do |t|
      t.references :customer_notification, foreign_key: { to_table: :cm_customer_notifications }, index: true
      t.references :taxon, foreign_key: { to_table: :spree_taxons }, index: true

      t.timestamps
    end
  end
end
