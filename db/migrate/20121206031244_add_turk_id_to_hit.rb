class AddTurkIdToHit < ActiveRecord::Migration
  def change
    add_column :hits, :turk_id, :integer
  end
end
