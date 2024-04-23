class CreateCmProductCompletionSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_product_completion_steps, if_not_exists: true do |t|
      t.string :type
      t.string :title
      t.string :action_label

      t.integer :position, default: 0, null: false

      t.text :description
      t.text :preferences

      t.references :product, foreign_key: { to_table: :spree_products }, index: true

      t.timestamps
    end
  end
end
