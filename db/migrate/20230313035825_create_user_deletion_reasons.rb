class CreateUserDeletionReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :user_deletion_reasons, if_not_exists: true do |t|
      t.string :title
      t.boolean :skip_reason
      t.text :reason_desc

      t.timestamps
    end
  end
end
