class RenameUserIdToTurkId < ActiveRecord::Migration
  def up
  	rename_column :votes, :user_id, :turk_id
  end

  def down
  	rename_column :votes, :turk_id, :user_id
  end
end
