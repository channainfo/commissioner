class CreateSpreeCmCommissionerUserDeletionSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_deletion_surveys do |t|
      t.references :user
      t.text :optional_reason
      t.integer :user_deletion_reason_id, null: false

      t.timestamps
    end
  end
end
