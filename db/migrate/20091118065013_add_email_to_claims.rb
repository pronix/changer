class AddEmailToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :email, :string
  end

  def self.down
    remove_column :claims, :email
  end
end
