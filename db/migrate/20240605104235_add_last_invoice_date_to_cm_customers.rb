class AddLastInvoiceDateToCmCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customers, :last_invoice_date, :date, null: true, if_not_exists: true
  end
end
