class AddKindToSpreeOptionTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_option_types, :kind, :integer, null: false, default: 0
  end
end
