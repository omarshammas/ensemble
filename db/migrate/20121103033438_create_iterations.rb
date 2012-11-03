class CreateIterations < ActiveRecord::Migration
  def change
    create_table :iterations do |t|
      t.integer :task_id
      t.integer :state

      t.timestamps
    end
  end
end
