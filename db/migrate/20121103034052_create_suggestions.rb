class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.integer :task_id
      t.integer :user_id
      t.integer :interation_id
      t.string :body
      t.integer :vote_count
      t.boolean :sent, :default => false
      t.integer :accepted, :default => 0

      t.timestamps
    end
  end
end
