class CreateTurks < ActiveRecord::Migration
  def change
    create_table :turks do |t|
      t.string :code

      t.timestamps
    end
  end
end
