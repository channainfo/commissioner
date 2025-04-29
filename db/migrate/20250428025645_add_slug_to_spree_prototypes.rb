class AddSlugToSpreePrototypes < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_prototypes, :slug, :string, if_not_exists: true
    add_index :spree_prototypes, :slug, unique: true, if_not_exists: true
  end
end
