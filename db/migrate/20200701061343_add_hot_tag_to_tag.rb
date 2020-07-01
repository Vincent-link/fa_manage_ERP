class AddHotTagToTag < ActiveRecord::Migration[6.0]
  def change
    TagCategory.create(name: "热门标签")
  end
end
