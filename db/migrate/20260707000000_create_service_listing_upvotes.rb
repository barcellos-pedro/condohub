class CreateServiceListingUpvotes < ActiveRecord::Migration[8.1]
  def change
    create_table :service_listing_upvotes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service_listing, null: false, foreign_key: true

      t.timestamps

      t.index [ :user_id, :service_listing_id ], unique: true
    end
  end
end
