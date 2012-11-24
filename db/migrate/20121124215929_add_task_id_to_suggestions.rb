class AddTaskIdToSuggestions < ActiveRecord::Migration
  def change
    add_column :suggestions, :task_id, :integer
  end
end
