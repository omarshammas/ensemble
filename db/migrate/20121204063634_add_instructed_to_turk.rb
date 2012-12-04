class AddInstructedToTurk < ActiveRecord::Migration
  def change
    add_column :turks, :instructed_first, :boolean, {:default => false}
    add_column :turks, :instructed_second, :boolean, {:default => false}
  end
end
