class RemoveTagIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index ActsAsTaggableOn.tags_table, :name
  end
end
