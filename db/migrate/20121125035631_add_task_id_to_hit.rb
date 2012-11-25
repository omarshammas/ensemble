class AddTaskIdToHit < ActiveRecord::Migration
  def change
    add_column :hits, :task_id, :integer
  end
end
