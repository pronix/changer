class AddMd5ToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :md5, :string
    add_index :claims, :md5, :unique => true
  end

  def self.down
    remove_column :claims, :md5
  end
end
