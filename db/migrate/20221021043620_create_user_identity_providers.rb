class CreateUserIdentityProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :cm_user_identity_providers do |t|
      t.integer :user_id
      t.integer :identity_type
      t.string :sub
      t.string :email

      t.timestamps
    end

    add_index :cm_user_identity_providers, [:user_id, :identity_type], unique: true
    add_index :cm_user_identity_providers, [:identity_type, :sub], unique: true
    add_foreign_key :cm_user_identity_providers, :"#{Spree.user_class.table_name}", column: :user_id
  end
end
