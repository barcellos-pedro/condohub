class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, null: false, default: "resident"

      t.timestamps

      t.index :email_address, unique: true
    end

    add_reference :users, :condominium, null: false
    add_foreign_key :users, :condominiums
  end
end
