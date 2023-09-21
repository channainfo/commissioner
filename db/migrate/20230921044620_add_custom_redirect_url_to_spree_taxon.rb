class AddCustomRedirectUrlToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :custom_redirect_url, :string, if_not_exists: true
  end
end
