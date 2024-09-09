class AddAttrTypeToSpreeOptionTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_option_types, :attr_type, :string, :default => 'string', if_not_exists: true
  end
end
