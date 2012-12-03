class AddTurkIdToPoint < ActiveRecord::Migration
  def change
    add_column :points, :turk_id, :integer
  end
end
