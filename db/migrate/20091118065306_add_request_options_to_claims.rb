class AddRequestOptionsToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :request_options, :text
  end

  def self.down
    remove_column :claims, :request_options
  end
end
