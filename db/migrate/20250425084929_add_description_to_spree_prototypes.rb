class AddDescriptionToSpreePrototypes < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_prototypes, :description, :text, if_not_exists: true
  end
end
