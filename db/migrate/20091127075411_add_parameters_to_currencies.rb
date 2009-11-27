class AddParametersToCurrencies < ActiveRecord::Migration
  def self.up
    add_column :currencies, :parameters, :text
  end

  def self.down
    remove_column :currencies, :parameters
  end
end
