class RemoveTaxonIdFromCmCustomer < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_customers, :taxon_id, :bigint, if_exists: true
  end
end
