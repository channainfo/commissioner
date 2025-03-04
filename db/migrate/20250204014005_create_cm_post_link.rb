class CreateCmPostLink < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_post_links do |t|
      t.string :title
      t.string :description
      t.string :url
      t.references :product, null: false, foreign_key: { to_table: :spree_products }

      t.timestamps
    end

    add_index :cm_post_links, :product_id, unique: true
  end
end
