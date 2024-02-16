class AddInvoiceIssuedDateToSpreeCmCommissionerInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_invoices, :invoice_issued_date, :date, null: true, if_not_exists: true
  end
end
