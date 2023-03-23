class CreateCmInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_invoices do |t|
      t.datetime :date
      t.string :invoice_number, null: false
      t.references :order, foreign_key: { to_table: :spree_orders }
      t.references :vendor, foreign_key: { to_table: :spree_vendors }
      t.timestamps
    end
  end
end
