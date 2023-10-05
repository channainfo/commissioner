class AddKindToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :kind, :integer, null: false, default: 0, if_not_exists: true
  end
end
