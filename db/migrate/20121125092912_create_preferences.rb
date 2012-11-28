class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :task_id
      t.integer :turk_id
      t.text :body

      t.timestamps
    end
  end
end
