class AddSuggestableIdAndSuggestableTypeToSuggestions < ActiveRecord::Migration
  def change
    add_column :suggestions, :suggestable_id, :integer
    add_column :suggestions, :suggestable_type, :string
  end
end
