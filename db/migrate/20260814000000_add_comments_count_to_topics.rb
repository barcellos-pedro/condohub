class AddCommentsCountToTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :comments_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE topics SET comments_count = (
            SELECT COUNT(*) FROM comments WHERE comments.topic_id = topics.id
          )
        SQL
      end
    end
  end
end
