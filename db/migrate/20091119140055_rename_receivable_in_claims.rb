class RenameReceivableInClaims < ActiveRecord::Migration
  def self.up
    rename_column :claims, :receivable, :receivable_source # сумма к получению в исходной валюте
    add_column :claims, :receivable_receive, :float # сумма к получению в обменной валюте
  end

  def self.down
    rename_column :claims, :receivable_source, :receivable
    remove_column :claims, :receivable_receive
  end
end
