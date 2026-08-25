class CreateCommentRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :comment_ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :comment_ratings, [ :user_id, :comment_id ], unique: true
  end
end
