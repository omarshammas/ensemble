class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.string :body
      t.boolean :isPro
      t.integer :suggestion_id

      t.timestamps
    end
  end
end
