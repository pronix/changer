class AddFeeToPathWays < ActiveRecord::Migration
  def self.up
    add_column :path_ways, :fee, :float # процент комисии который возьмет сервсис себе от суммы обмена
  end

  def self.down
    remove_column :path_ways, :fee
  end
end
