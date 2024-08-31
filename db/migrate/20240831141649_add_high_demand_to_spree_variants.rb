class AddHighDemandToSpreeVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_variants, :high_demand, :boolean, default: false, if_not_exists: true
  end
end
