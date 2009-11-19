class AddFeeToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :fee, :float           # коммисия которая будет сниматься исочником
    add_column :claims, :service_fee, :float   # коммисия которая будет сниматься сервисом
    add_column :claims, :receivable, :float    # сумма к получению
  end

  def self.down
    remove_column :claims, :fee
    remove_column :claims, :service_fee
    remove_column :claims, :receivable
  end
end
