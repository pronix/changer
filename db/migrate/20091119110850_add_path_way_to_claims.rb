class AddPathWayToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :path_way_id, :integer
  end

  def self.down
    remove_column :claims, :path_way_id
  end
end
