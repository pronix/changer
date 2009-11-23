class AddPaymentOptionsToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :payment_options, :text
  end

  def self.down
    remove_column :claims, :payment_options
  end
end
