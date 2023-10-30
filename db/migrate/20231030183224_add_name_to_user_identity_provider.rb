class AddNameToUserIdentityProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_user_identity_providers, :name, :string, if_not_exists: true
  end
end
