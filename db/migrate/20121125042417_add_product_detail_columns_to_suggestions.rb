class AddProductDetailColumnsToSuggestions < ActiveRecord::Migration
  def change
    add_column :suggestions, :price, :integer
    add_column :suggestions, :product_name, :string
    add_column :suggestions, :product_link, :string
    add_column :suggestions, :image_url, :string
    add_column :suggestions, :retailer, :string
  end
end
