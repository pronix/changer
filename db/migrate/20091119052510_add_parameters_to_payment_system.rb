class AddParametersToPaymentSystem < ActiveRecord::Migration
  def self.up
    add_column :payment_systems, :parameters, :text # параметры для платежной системы
  end

  def self.down
    remove_column :payment_systems, :parameters    
  end
end
