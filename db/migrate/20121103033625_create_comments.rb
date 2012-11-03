class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :task_id
      t.integer :user_id
      t.integer :iteration_id
      t.string :body

      t.timestamps
    end
  end
end
