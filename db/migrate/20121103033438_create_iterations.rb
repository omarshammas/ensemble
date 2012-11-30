class CreateIterations < ActiveRecord::Migration
  def change
    create_table :iterations do |t|
      t.integer :task_id
      t.boolean :finished, :default => false

      t.timestamps
    end
  end
end
