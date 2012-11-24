class RemoveTaskIdAndUserIdFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :user_id
    remove_column :comments, :task_id
  end

  def down
    add_column :comments, :task_id, :integer
    add_column :comments, :user_id, :integer
  end
end
