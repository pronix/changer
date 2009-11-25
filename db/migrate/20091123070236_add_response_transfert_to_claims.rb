class AddResponseTransfertToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :response_transfert, :text
  end

  def self.down
    remove_column :claims, :response_transfert
  end
end
