class CreatePostRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :post_ratings do |t|
      t.integer :user_id, null: false
      t.integer :post_id, null: false
      t.integer :value, null: false
      t.timestamps
    end

    add_index :post_ratings, :user_id
    add_index :post_ratings, :post_id
    add_index :post_ratings, [:user_id, :post_id], unique: true

    add_foreign_key :post_ratings, :users
    add_foreign_key :post_ratings, :posts
  end
end
