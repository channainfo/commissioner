class AddCodeToCmPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :code, :string
  end
end
