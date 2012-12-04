class AddInterfaceToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :interface, :string
  end
end