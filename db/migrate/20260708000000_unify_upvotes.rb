class UnifyUpvotes < ActiveRecord::Migration[8.1]
  def change
    add_column :upvotes, :upvotable_type, :string
    add_column :upvotes, :upvotable_id, :integer

    Upvote.where.not(topic_id: nil).update_all("upvotable_type = 'Topic', upvotable_id = topic_id")

    change_column_null :upvotes, :topic_id, true

    execute <<-SQL
      INSERT INTO upvotes (user_id, upvotable_type, upvotable_id, created_at, updated_at)
      SELECT user_id, 'ServiceListing', service_listing_id, created_at, updated_at
      FROM service_listing_upvotes
    SQL

    change_column_null :upvotes, :upvotable_type, false
    change_column_null :upvotes, :upvotable_id, false

    remove_index :upvotes, name: "index_upvotes_on_user_id_and_topic_id"
    remove_column :upvotes, :topic_id

    add_index :upvotes, [ :user_id, :upvotable_type, :upvotable_id ], unique: true, name: "index_upvotes_on_user_id_and_upvotable"

    drop_table :service_listing_upvotes

    execute <<-SQL
      UPDATE topics SET upvotes_count = (
        SELECT COUNT(*) FROM upvotes WHERE upvotable_type = 'Topic' AND upvotable_id = topics.id
      )
    SQL

    execute <<-SQL
      UPDATE service_listings SET upvotes_count = (
        SELECT COUNT(*) FROM upvotes WHERE upvotable_type = 'ServiceListing' AND upvotable_id = service_listings.id
      )
    SQL
  end
end
