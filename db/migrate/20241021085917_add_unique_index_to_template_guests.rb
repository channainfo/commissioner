class AddUniqueIndexToTemplateGuests < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_template_guests, [:user_id, :is_default], unique: true, where: 'is_default = true', name: 'index_user_default'
  end
end
