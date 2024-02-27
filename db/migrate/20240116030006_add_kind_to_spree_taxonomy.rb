# This migration comes from spree_cm_commissioner (originally 20231005021329)
class AddKindToSpreeTaxonomy < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxonomies, :kind, :integer, null: false, default: 0, if_not_exists: true
  end
end
