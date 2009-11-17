class AddOptionPurseToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :option_purse, :text
  end

  def self.down
    remove_column :claims, :option_purse
  end
end
