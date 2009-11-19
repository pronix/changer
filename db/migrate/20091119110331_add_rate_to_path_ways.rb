class AddRateToPathWays < ActiveRecord::Migration
  def self.up
    add_column :path_ways, :rate, :float
  end

  def self.down
    remove_column :path_ways, :rate
  end
end
