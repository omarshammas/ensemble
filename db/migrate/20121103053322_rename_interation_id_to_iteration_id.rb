class RenameInterationIdToIterationId < ActiveRecord::Migration
  def up
    rename_column :suggestions, :interation_id, :iteration_id
  end

  def down
    rename_column :suggestions, :iteration_id, :interation_id
  end
end
