class AddSlugToTaxons < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :slug, :string, if_not_exists: true
    add_index :spree_taxons, :slug, unique: true

    Spree::Taxon.all.each do |taxon|
      taxon.set_slug
      taxon.save
    end
  end
end
