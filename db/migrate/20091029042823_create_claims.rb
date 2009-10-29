class CreateClaims < ActiveRecord::Migration
  # Заявка на обмен
  def self.up
    create_table :claims do |t|
      
      t.integer  :currency_source_id   # валюта источника
      t.integer  :currency_receiver_id # валюта приемника
      t.float    :summa                # сумма к обмену 
      
      t.text     :comment              # комментарий
      
      t.timestamps
    end
  end

  def self.down
    drop_table :claims
  end
end
