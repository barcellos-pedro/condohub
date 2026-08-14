class CreateWaitlistEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :waitlist_entries do |t|
      t.string :email_address, null: false
      t.string :locale

      t.timestamps

      t.index :email_address, unique: true
    end
  end
end
