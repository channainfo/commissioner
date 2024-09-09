class GenerateDefaultDeletionReasons < ActiveRecord::Migration[7.0]
  def change
    UserDeletionReason.generate_default_deletions
  end
end
