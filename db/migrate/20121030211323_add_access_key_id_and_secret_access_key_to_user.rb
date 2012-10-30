class AddAccessKeyIdAndSecretAccessKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_key_id, :string
    add_column :users, :secret_access_key, :string
  end
end
