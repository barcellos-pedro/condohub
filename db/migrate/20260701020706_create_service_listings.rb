class CreateServiceListings < ActiveRecord::Migration[8.1]
  def change
    create_table :service_listings do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :contact_info
      t.string :category, null: false
      t.integer :upvotes_count, null: false, default: 0

      t.timestamps
    end

    add_reference :service_listings, :condominium, null: false
    add_reference :service_listings, :user, null: false
    add_foreign_key :service_listings, :condominiums
    add_foreign_key :service_listings, :users

    add_index :service_listings, [:condominium_id, :category]
  end
end
