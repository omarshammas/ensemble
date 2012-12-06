class ChangePriceFormatInSuggestion < ActiveRecord::Migration
  def up
  	change_column :suggestions, :price, :decimal
  end

  def down
  	change_column :suggestions, :price, :integer
  end
end
