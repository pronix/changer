class CreateCurrencies < ActiveRecord::Migration
  # Список валют
  def self.up
    create_table :currencies do |t|
      t.string    :name              # наименование валюты
      t.string    :code              # код валюты
      t.integer   :payment_system_id # платежная система
      t.text      :description       # описание

      t.timestamps
    end
    
    add_index :currencies, :code
    add_index :currencies, :payment_system_id
    
  end

  def self.down
    drop_table :currencies
  end
end
