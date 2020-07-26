class ChangeCoverageInTag < ActiveRecord::Migration[6.0]
  def change
    remove_column :tags, :coverage
    add_column :tags, :coverage, :integer, array: true
  end
end
