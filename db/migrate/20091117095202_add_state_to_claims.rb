class AddStateToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :state, :string
    add_index :claims, :state
  end

  def self.down
    remove_column :claims, :state
  end
end
