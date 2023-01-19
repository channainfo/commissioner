class AddStarRatingToSpreeVendor < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :star_rating, :integer
  end
end
