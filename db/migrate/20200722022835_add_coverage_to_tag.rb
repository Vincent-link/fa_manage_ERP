class AddCoverageToTag < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :coverage, :integer, comment: "适用范围"
  end
end
