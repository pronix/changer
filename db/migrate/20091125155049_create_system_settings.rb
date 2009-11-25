class CreateSystemSettings < ActiveRecord::Migration
  def self.up
    create_table :system_settings do |t|
      t.string :code, :null => false, :unique => true
      t.string :name, :null => false
      t.text :setting
    end
    add_index :system_settings, :code, :unique => true
  end

  def self.down
    drop_table :system_settings
  end
end
