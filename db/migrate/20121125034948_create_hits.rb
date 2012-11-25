class CreateHits < ActiveRecord::Migration
  def change
    create_table :hits do |t|
      t.string :code
      t.string :h_id
      t.string :type_id
      t.string :url

      t.timestamps
    end
  end
end
