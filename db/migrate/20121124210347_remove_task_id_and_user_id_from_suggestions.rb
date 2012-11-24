class RemoveTaskIdAndUserIdFromSuggestions < ActiveRecord::Migration
  def up
    remove_column :suggestions, :user_id
    remove_column :suggestions, :task_id
  end

  def down
    add_column :suggestions, :task_id, :integer
    add_column :suggestions, :user_id, :integer
  end
end
