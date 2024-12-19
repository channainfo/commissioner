class AddCapToSpreeCalculator < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_calculators, :cap, :float, if_not_exists: true
  end
end
