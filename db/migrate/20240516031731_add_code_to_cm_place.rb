class AddCodeToCmPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :code, :string, if_not_exists: true
  end
end
