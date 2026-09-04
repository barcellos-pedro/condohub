class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :condominium, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :email_address, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [ :condominium_id, :email_address ]
  end
end
