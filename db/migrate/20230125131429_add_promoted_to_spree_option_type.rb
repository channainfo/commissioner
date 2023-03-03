class AddPromotedToSpreeOptionType < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_option_types, :promoted, :boolean, default: false, if_not_exists: true
  end
end


