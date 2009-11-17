class AddControllerToPaymentSystem < ActiveRecord::Migration
  def self.up
    add_column :payment_systems, :controller, :string
  end

  def self.down
    remove_column :payment_systems, :controller
  end
end
