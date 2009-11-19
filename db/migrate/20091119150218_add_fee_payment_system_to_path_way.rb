class AddFeePaymentSystemToPathWay < ActiveRecord::Migration
  def self.up
    add_column :path_ways, :fee_payment_system, :float 
    # % комиссии которую возьмет платежная система источник
  end

  def self.down
    remove_column :path_ways, :fee_payment_system
  end
end
