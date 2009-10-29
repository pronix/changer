class CreatePathWays < ActiveRecord::Migration
  def self.up
    create_table :path_ways do |t|
      t.integer  :currency_source_id   # валюта источника
      t.integer  :currency_receiver_id # валюта приемника
      t.float    :percent              # процент за перевод
      t.text     :description          # описание, примечание 
      t.timestamps
    end
    
    add_index :path_ways, :currency_receiver_id
    add_index :path_ways, :currency_source_id
    
  end

  def self.down
    drop_table :path_ways
  end
end
