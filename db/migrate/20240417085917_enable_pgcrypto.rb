class EnablePgcrypto < ActiveRecord::Migration[7.0]
  # https://medium.com/@technoblogueur/adding-uuid-column-to-rails-and-postgresql-table-46669a3b4d13
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
