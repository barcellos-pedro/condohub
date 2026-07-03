class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :topic_type, null: false, default: "discussion"
      t.integer :upvotes_count, null: false, default: 0

      t.timestamps
    end

    add_reference :topics, :condominium, null: false
    add_reference :topics, :user, null: false
    add_foreign_key :topics, :condominiums
    add_foreign_key :topics, :users

    add_index :topics, [ :condominium_id, :created_at ]
  end
end
