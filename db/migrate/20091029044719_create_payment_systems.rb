class CreatePaymentSystems < ActiveRecord::Migration
  # платежные системы
  def self.up
    create_table :payment_systems do |t|
      t.string :name        # Наименование
      t.text   :description # Описание

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_systems
  end
end
