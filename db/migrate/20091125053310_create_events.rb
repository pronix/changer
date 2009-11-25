class CreateEvents < ActiveRecord::Migration
  # Логирование заявки
  def self.up
    create_table :events do |t|
      t.integer :claim_id
      t.string  :message
      t.text    :parameters
      t.timestamps
    end
    add_index :events, :claim_id
  end

  def self.down
    drop_table :events
  end
end
