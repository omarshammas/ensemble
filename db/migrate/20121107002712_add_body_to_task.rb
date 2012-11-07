class AddBodyToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :body, :string
  end
end
