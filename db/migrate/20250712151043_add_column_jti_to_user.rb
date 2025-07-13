class AddColumnJtiToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :active_refresh_token_jti, :string
    add_index :users, :active_refresh_token_jti, unique: true
  end
end
