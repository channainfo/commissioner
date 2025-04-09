class AddNumberOfGuestsToVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_variants, :number_of_adults, :integer, default: 1, if_not_exists: true
    add_column :spree_variants, :number_of_kids, :integer, default: 0, if_not_exists: true
  end
end
